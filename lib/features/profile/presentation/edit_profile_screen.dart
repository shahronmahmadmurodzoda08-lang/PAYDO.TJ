import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/tj_cities.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/social_link_chip.dart';
import '../../../models/user_model.dart';
import 'profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _instagramCtrl;
  late final TextEditingController _whatsappCtrl;

  String? _selectedCity;
  bool _phoneVisible = false;
  bool _ageVisible = false;

  File? _pickedImage;
  String? _uploadedPhotoUrl;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameCtrl = TextEditingController(text: u.name);
    _nicknameCtrl = TextEditingController(text: u.nickname ?? '');
    _phoneCtrl = TextEditingController(text: u.phone ?? '');
    _ageCtrl = TextEditingController(text: u.age?.toString() ?? '');
    _instagramCtrl = TextEditingController(text: u.instagramUrl ?? '');
    _whatsappCtrl = TextEditingController(text: u.whatsapp ?? '');
    _selectedCity = u.city;
    _phoneVisible = u.phoneVisible;
    _ageVisible = u.ageVisible;
    _uploadedPhotoUrl = u.photoUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _instagramCtrl.dispose();
    _whatsappCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (xfile == null) return;

    setState(() => _pickedImage = File(xfile.path));

    final controller =
        ref.read(editProfileControllerProvider(widget.user.uid).notifier);
    final url = await controller.pickAndUploadPhoto(
      File(xfile.path),
      oldUrl: widget.user.photoUrl,
    );

    if (url != null && mounted) {
      setState(() => _uploadedPhotoUrl = url);
    }
  }

  Future<void> _save() async {
    final controller =
        ref.read(editProfileControllerProvider(widget.user.uid).notifier);

    final ageText = _ageCtrl.text.trim();
    final age = ageText.isEmpty ? null : int.tryParse(ageText);

    final ok = await controller.save(
      name: _nameCtrl.text.trim(),
      nickname: _nicknameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      age: age,
      city: _selectedCity,
      instagramUrl: _instagramCtrl.text.trim(),
      whatsapp: _whatsappCtrl.text.trim(),
      photoUrl: _uploadedPhotoUrl,
      phoneVisible: _phoneVisible,
      ageVisible: _ageVisible,
    );

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
    final state = ref.watch(editProfileControllerProvider(widget.user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тағйири профил'),
        actions: [
          TextButton(
            onPressed: state.isSaving ? null : _save,
            child: state.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(AppStrings.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!) as ImageProvider
                      : (_uploadedPhotoUrl != null
                          ? CachedNetworkImageProvider(_uploadedPhotoUrl!)
                          : null),
                  child: (_pickedImage == null && _uploadedPhotoUrl == null)
                      ? const Icon(Icons.person,
                          size: 48, color: AppColors.primary)
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: state.isUploadingPhoto ? null : _pickImage,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: state.isUploadingPhoto
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.camera_alt_rounded,
                              size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Ном'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nicknameCtrl,
            decoration: const InputDecoration(labelText: 'Nickname'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: const InputDecoration(labelText: 'Шаҳр'),
            items: TjCities.all
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCity = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Телефон'),
          ),
          VisibilityToggleRow(
            label: 'Телефонро нишон додан',
            isVisible: _phoneVisible,
            onChanged: (v) => setState(() => _phoneVisible = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ageCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Синну сол'),
          ),
          VisibilityToggleRow(
            label: 'Синну солро нишон додан',
            isVisible: _ageVisible,
            onChanged: (v) => setState(() => _ageVisible = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _instagramCtrl,
            decoration: const InputDecoration(
              labelText: 'Instagram',
              hintText: '@username ё https://instagram.com/username',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _whatsappCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'WhatsApp',
              hintText: '+992 XX XXX XX XX',
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
