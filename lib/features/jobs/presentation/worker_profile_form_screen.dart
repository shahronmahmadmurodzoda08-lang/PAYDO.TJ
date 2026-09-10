import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/tj_cities.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../models/worker_profile_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import 'jobs_providers.dart';

class WorkerProfileFormScreen extends ConsumerStatefulWidget {
  const WorkerProfileFormScreen({super.key});

  @override
  ConsumerState<WorkerProfileFormScreen> createState() => _WorkerProfileFormScreenState();
}

class _WorkerProfileFormScreenState extends ConsumerState<WorkerProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _professionCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _expectedSalaryCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  String? _selectedCity;
  bool _isVisible = true;
  bool _initialized = false;

  void _fillFrom(WorkerProfileModel? profile) {
    if (_initialized || profile == null) return;
    _initialized = true;
    _professionCtrl.text = profile.profession;
    _experienceCtrl.text = profile.experience ?? '';
    _educationCtrl.text = profile.education ?? '';
    _expectedSalaryCtrl.text = profile.expectedSalary?.toStringAsFixed(0) ?? '';
    _skillsCtrl.text = profile.skills.join(', ');
    _descriptionCtrl.text = profile.description;
    _ageCtrl.text = profile.age?.toString() ?? '';
    _selectedCity = profile.city;
    _isVisible = profile.isVisible;
  }

  @override
  void dispose() {
    _professionCtrl.dispose();
    _experienceCtrl.dispose();
    _educationCtrl.dispose();
    _expectedSalaryCtrl.dispose();
    _skillsCtrl.dispose();
    _descriptionCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Лутфан шаҳрро интихоб кунед.')));
      return;
    }

    final me = ref.read(authStateProvider).value;
    if (me == null) return;

    final profile = WorkerProfileModel(
      uid: me.uid,
      name: me.name,
      photoUrl: me.photoUrl,
      age: int.tryParse(_ageCtrl.text.trim()),
      city: _selectedCity!,
      profession: _professionCtrl.text.trim(),
      experience: _experienceCtrl.text.trim().isEmpty ? null : _experienceCtrl.text.trim(),
      education: _educationCtrl.text.trim().isEmpty ? null : _educationCtrl.text.trim(),
      expectedSalary: double.tryParse(_expectedSalaryCtrl.text.trim()),
      skills: _skillsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      description: _descriptionCtrl.text.trim(),
      isVisible: _isVisible,
    );

    final ok = await ref.read(jobsActionControllerProvider.notifier).saveWorkerProfile(profile);

    if (ok) {
      final currentUser = await ref.read(profileRepositoryProvider).getUser(me.uid);
      if (!currentUser.accountTypes.contains(AccountType.worker)) {
        await ref.read(profileRepositoryProvider).updateProfile(
              uid: me.uid,
              accountTypes: [...currentUser.accountTypes, AccountType.worker],
            );
      }
    }

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Профили корҷӳ нигоҳ дошта шуд.')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.somethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final myProfileAsync = ref.watch(myWorkerProfileProvider);
    final state = ref.watch(jobsActionControllerProvider);

    myProfileAsync.whenData(_fillFrom);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профили корҷӳи ман'),
        actions: [
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
                  TextFormField(
                    controller: _professionCtrl,
                    decoration: const InputDecoration(labelText: 'Ихтисос *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Ҳатмист' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ageCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Синну сол'),
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
                    controller: _experienceCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Таҷриба', hintText: 'масалан: 2 сол'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _educationCtrl,
                    decoration: const InputDecoration(labelText: 'Маълумот'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _expectedSalaryCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Маоши дилхоҳ (сомонӣ)'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _skillsCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Малакаҳо (бо вергул ҷудо кунед)',
                        hintText: 'масалан: Excel, мулоқот бо мизоҷ'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Дар бораи худ'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Дар ҷустуҷӳи корфармоён намоён бошад'),
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
