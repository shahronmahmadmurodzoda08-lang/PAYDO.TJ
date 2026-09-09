import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/product_categories.dart';
import '../../../core/constants/tj_cities.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/product_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../business/presentation/business_providers.dart';
import 'product_management_providers.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final ProductModel? existing;
  const AddEditProductScreen({super.key, this.existing});

  @override
  ConsumerState<AddEditProductScreen> createState() =>
      _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _oldPriceCtrl;
  late final TextEditingController _quantityCtrl;

  String? _selectedCategory;
  String? _selectedCity;
  bool _deliveryAvailable = false;
  final List<String> _images = [];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descriptionCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(text: p?.price.toStringAsFixed(0) ?? '');
    _oldPriceCtrl =
        TextEditingController(text: p?.oldPrice?.toStringAsFixed(0) ?? '');
    _quantityCtrl = TextEditingController(text: p?.quantity.toString() ?? '1');
    _selectedCategory = p?.category;
    _selectedCity = p?.city;
    _deliveryAvailable = p?.deliveryAvailable ?? false;
    if (p != null) _images.addAll(p.images);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _oldPriceCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _addImage() async {
    if (_images.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ҳадди аксар 6 сурат.')),
      );
      return;
    }
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    final xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (xfile == null) return;

    final url = await ref
        .read(productFormControllerProvider.notifier)
        .uploadImage(sellerId: uid, imageFile: File(xfile.path));

    if (url != null && mounted) {
      setState(() => _images.add(url));
    }
  }

  void _removeImage(String url) {
    setState(() => _images.remove(url));
    // Silent best-effort cleanup аз Storage (ниг. эзоҳи repository).
    ref.read(productManagementRepositoryProvider).deleteProductImage(url);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Лутфан категория ва шаҳрро интихоб кунед.')),
      );
      return;
    }
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Лутфан ҳадди ақал як сурат илова кунед.')),
      );
      return;
    }

    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final oldPriceText = _oldPriceCtrl.text.trim();
    final oldPrice = oldPriceText.isEmpty ? null : double.tryParse(oldPriceText);
    final quantity = int.tryParse(_quantityCtrl.text.trim()) ?? 0;
    int? discount;
    if (oldPrice != null && oldPrice > price && oldPrice > 0) {
      discount = (((oldPrice - price) / oldPrice) * 100).round();
    }

    // Агар корбар бизнес дошта бошад, маҳсулот ба он пайваст мешавад.
    final myBusiness = ref.read(myBusinessProvider).valueOrNull;

    final controller = ref.read(productFormControllerProvider.notifier);
    bool ok;

    if (_isEditing) {
      final updated = ProductModel(
        id: widget.existing!.id,
        sellerId: widget.existing!.sellerId,
        businessId: widget.existing!.businessId,
        name: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        price: price,
        oldPrice: oldPrice,
        discount: discount,
        images: _images,
        category: _selectedCategory!,
        quantity: quantity,
        city: _selectedCity!,
        deliveryAvailable: _deliveryAvailable,
        rating: widget.existing!.rating,
        reviewsCount: widget.existing!.reviewsCount,
        isHidden: widget.existing!.isHidden,
      );
      ok = await controller.saveEdit(updated);
    } else {
      final newProduct = ProductModel(
        id: '',
        sellerId: uid,
        businessId: myBusiness?.id,
        name: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        price: price,
        oldPrice: oldPrice,
        discount: discount,
        images: _images,
        category: _selectedCategory!,
        quantity: quantity,
        city: _selectedCity!,
        deliveryAvailable: _deliveryAvailable,
      );
      ok = await controller.saveNew(newProduct);
    }

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.somethingWentWrong)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productFormControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Тағйири маҳсулот' : 'Маҳсулоти нав'),
        actions: [
          TextButton(
            onPressed: state.isSaving ? null : _save,
            child: state.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text(AppStrings.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Суратҳо (${_images.length}/6)',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._images.map(
                    (url) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: InkWell(
                              onTap: () => _removeImage(url),
                              child: const CircleAvatar(
                                radius: 11,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close_rounded,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: state.isUploadingImage ? null : _addImage,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: state.isUploadingImage
                          ? const Center(child: CircularProgressIndicator())
                          : const Icon(Icons.add_a_photo_outlined,
                              color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Номи маҳсулот *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ҳатмист' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Тавсиф'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Нарх (сомонӣ) *'),
                    validator: (v) {
                      final n = double.tryParse(v?.trim() ?? '');
                      if (n == null || n <= 0) return 'Нархи дуруст ворид кунед';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _oldPriceCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Нархи кӯҳна (ихтиёрӣ)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Миқдор (дона) *'),
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                if (n == null || n < 0) return 'Миқдори дуруст ворид кунед';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Категория *'),
              items: ProductCategories.all
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(ProductCategories.labelOf(c)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(labelText: 'Шаҳр *'),
              items: TjCities.all
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCity = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Доставка дорад'),
              value: _deliveryAvailable,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _deliveryAvailable = v),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
