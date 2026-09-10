import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/service_categories.dart';
import '../../../core/constants/tj_cities.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/service_provider_model.dart';
import '../../../models/user_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import 'provider_service_orders_screen.dart';
import 'services_providers.dart';

class ProviderProfileFormScreen extends ConsumerStatefulWidget {
  const ProviderProfileFormScreen({super.key});

  @override
  ConsumerState<ProviderProfileFormScreen> createState() =>
      _ProviderProfileFormScreenState();
}

class _ProviderProfileFormScreenState extends ConsumerState<ProviderProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();

  String? _selectedCategory;
  String? _selectedCity;
  bool _isVisible = true;
  bool _initialized = false;

  void _fillFrom(ServiceProviderModel? profile) {
    if (_initialized || profile == null) return;
    _initialized = true;
    _descriptionCtrl.text = profile.description;
    _priceCtrl.text = profile.price?.toStringAsFixed(0) ?? '';
    _phoneCtrl.text = profile.phone ?? '';
    _whatsappCtrl.text = profile.whatsapp ?? '';
    _instagramCtrl.text = profile.instagramUrl ?? '';
    _selectedCategory = profile.serviceCategory;
    _selectedCity = profile.city;
    _isVisible = profile.isVisible;
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _instagramCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Лутфан категория ва шаҳрро интихоб кунед.')));
      return;
    }

    final me = ref.read(authStateProvider).value;
    if (me == null) return;

    final provider = ServiceProviderModel(
      uid: me.uid,
      name: me.name,
      photoUrl: me.photoUrl,
      serviceCategory: _selectedCategory!,
      description: _descriptionCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text.trim()),
      city: _selectedCity!,
      phone: _phoneCtrl.text.trim(),
      whatsapp: _whatsappCtrl.text.trim(),
      instagramUrl: _instagramCtrl.text.trim(),
      isVisible: _isVisible,
    );

    final ok = await ref.read(servicesActionControllerProvider.notifier).saveProfile(provider);

    if (ok) {
      final currentUser = await ref.read(profileRepositoryProvider).getUser(me.uid);
      // Дар спецификатсия accountType барои хизматрасон алоҳида зикр
      // нашудааст (banди 6 танҳо user/business/worker/employer/courier/
      // admin-ро номбар мекунад) — бинобар ин 'business'-ро истифода
      // мебарем, зеро хизматрасон низ як намуди "provider" аст.
      if (!currentUser.accountTypes.contains(AccountType.business)) {
        await ref.read(profileRepositoryProvider).updateProfile(
              uid: me.uid,
              accountTypes: [...currentUser.accountTypes, AccountType.business],
            );
      }
    }

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Профили хизматрасон нигоҳ дошта шуд.')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.somethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final myProfileAsync = ref.watch(myProviderProfileProvider);
    final state = ref.watch(servicesActionControllerProvider);

    myProfileAsync.whenData(_fillFrom);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профили хизматрасони ман'),
        actions: [
          if (myProfileAsync.valueOrNull != null)
            IconButton(
              icon: const Icon(Icons.receipt_long_outlined),
              tooltip: 'Фармоишҳои омада',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProviderServiceOrdersScreen()),
              ),
            ),
          TextButton(
            onPressed: state.isSaving ? null : _save,
            child: state.isSaving
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text(AppStrings.save),
          ),
        ],
      ),
      body: myProfileAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Намуди хизмат *'),
                    items: ServiceCategories.all
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(ServiceCategories.labelOf(c))))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: const InputDecoration(labelText: 'Шаҳр *'),
                    items:
                        TjCities.all.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _selectedCity = v),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Нарх аз (сомонӣ)'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Тавсифи хизмат'),
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
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Дар ҷустуҷӯ намоён бошад'),
                    value: _isVisible,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isVisible = v),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
