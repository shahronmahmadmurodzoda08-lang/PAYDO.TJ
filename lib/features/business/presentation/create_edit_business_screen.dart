import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/tj_cities.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/business_model.dart';
import '../../auth/presentation/auth_providers.dart';
import 'business_providers.dart';

class CreateEditBusinessScreen extends ConsumerStatefulWidget {
  final BusinessModel? existing;
  const CreateEditBusinessScreen({super.key, this.existing});

  @override
  ConsumerState<CreateEditBusinessScreen> createState() =>
      _CreateEditBusinessScreenState();
}

class _CreateEditBusinessScreenState
    extends ConsumerState<CreateEditBusinessScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _instagramCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _workingHoursCtrl;

  String? _selectedCity;
  bool _deliveryAvailable = false;
  String? _logoUrl;
  String? _coverUrl;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final b = widget.existing;
    _nameCtrl = TextEditingController(text: b?.businessName ?? '');
    _descriptionCtrl = TextEditingController(text: b?.description ?? '');
    _phoneCtrl = TextEditingController(text: b?.phone ?? '');
    _whatsappCtrl = TextEditingController(text: b?.whatsapp ?? '');
    _instagramCtrl = TextEditingController(text: b?.instagramUrl ?? '');
    _addressCtrl = TextEditingController(text: b?.address ?? '');
    _workingHoursCtrl = TextEditingController(text: b?.workingHours ?? '');
    _selectedCity = b?.city;
    _deliveryAvailable = b?.deliveryAvailable ?? false;
    _logoUrl = b?.logoUrl;
    _coverUrl = b?.coverImageUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _instagramCtrl.dispose();
    _addressCtrl.dispose();
    _workingHoursCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool isLogo}) async {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    final xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: isLogo ? 512 : 1280,
    );
    if (xfile == null) return;

    final url = await ref
        .read(saveBusinessControllerProvider.notifier)
        .uploadImage(ownerId: uid, imageFile: File(xfile.path), isLogo: isLogo);

    if (url != null && mounted) {
      setState(() => isLogo ? _logoUrl = url : _coverUrl = url);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Лутфан шаҳрро интихоб кунед.')),
      );
      return;
    }

    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    final business = BusinessModel(
      id: widget.existing?.id ?? uid,
      ownerId: uid,
      businessName: _nameCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      whatsapp: _whatsappCtrl.text.trim(),
      instagramUrl: _instagramCtrl.text.trim(),
      city: _selectedCity!,
      address: _addressCtrl.text.trim(),
      workingHours: _workingHoursCtrl.text.trim(),
      deliveryAvailable: _deliveryAvailable,
      logoUrl: _logoUrl,
      coverImageUrl: _coverUrl,
      rating: widget.existing?.rating ?? 0,
      reviewsCount: widget.existing?.reviewsCount ?? 0,
      isVerified: widget.existing?.isVerified ?? false,
    );

    final ok =
        await ref.read(saveBusinessControllerProvider.notifier).save(business);

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
    final state = ref.watch(saveBusinessControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Тағйири бизнес' : 'Кушодани бизнес'),
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
            _ImagePickerTile(
              label: 'Cover',
              url: _coverUrl,
              height: 120,
              isUploading: state.isUploadingImage,
              onTap: () => _pickImage(isLogo: false),
            ),
            const SizedBox(height: 16),
            Center(
              child: _ImagePickerTile(
                label: 'Logo',
                url: _logoUrl,
                height: 88,
                width: 88,
                shape: BoxShape.circle,
                isUploading: state.isUploadingImage,
                onTap: () => _pickImage(isLogo: true),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Номи бизнес *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ҳатмист' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Тавсиф'),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Суроға'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Телефон'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _whatsappCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'WhatsApp'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instagramCtrl,
              decoration: const InputDecoration(labelText: 'Instagram'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _workingHoursCtrl,
              decoration: const InputDecoration(
                labelText: 'Соатҳои корӣ',
                hintText: 'масалан: 9:00 - 20:00',
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Хизматрасонии доставка дорад'),
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

class _ImagePickerTile extends StatelessWidget {
  final String label;
  final String? url;
  final double height;
  final double? width;
  final BoxShape shape;
  final bool isUploading;
  final VoidCallback onTap;

  const _ImagePickerTile({
    required this.label,
    required this.url,
    required this.height,
    this.width,
    this.shape = BoxShape.rectangle,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isUploading ? null : onTap,
      borderRadius:
          shape == BoxShape.circle ? BorderRadius.circular(999) : BorderRadius.circular(16),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(16)
              : null,
          image: url != null
              ? DecorationImage(
                  image: CachedNetworkImageProvider(url!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: url == null
            ? Center(
                child: isUploading
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined,
                              color: AppColors.primary),
                          Text(label,
                              style: const TextStyle(
                                  color: AppColors.primary, fontSize: 12)),
                        ],
                      ),
              )
            : (isUploading
                ? Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : null),
      ),
    );
  }
}
