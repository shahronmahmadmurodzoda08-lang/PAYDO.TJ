import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user_model.dart';
import '../data/profile_repository_impl.dart';
import '../domain/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

/// Ҷараёни зинда (real-time)-и профили корбар бо uid-и додашуда.
/// family истифода мешавад, то дар оянда экрани "профили дигар корбар"
/// (масалан диданӣ дар chat/product) бе provider-и нав кор кунад.
final watchUserProvider =
    StreamProvider.family<UserModel, String>((ref, uid) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.watchUser(uid);
});

/// Ҳолати муваққатии edit-form + амали "Нигоҳ доштан".
class EditProfileState {
  final bool isSaving;
  final bool isUploadingPhoto;
  final String? errorMessage;

  const EditProfileState({
    this.isSaving = false,
    this.isUploadingPhoto = false,
    this.errorMessage,
  });

  EditProfileState copyWith({
    bool? isSaving,
    bool? isUploadingPhoto,
    String? errorMessage,
  }) {
    return EditProfileState(
      isSaving: isSaving ?? this.isSaving,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      errorMessage: errorMessage,
    );
  }
}

class EditProfileController extends StateNotifier<EditProfileState> {
  final ProfileRepository _repository;
  final String uid;

  EditProfileController(this._repository, this.uid)
      : super(const EditProfileState());

  Future<String?> pickAndUploadPhoto(File imageFile, {String? oldUrl}) async {
    state = state.copyWith(isUploadingPhoto: true, errorMessage: null);
    try {
      final url = await _repository.uploadProfilePhoto(
        uid: uid,
        imageFile: imageFile,
        oldPhotoUrl: oldUrl,
      );
      state = state.copyWith(isUploadingPhoto: false);
      return url;
    } catch (e) {
      state = state.copyWith(
        isUploadingPhoto: false,
        errorMessage: 'Хатогии боркунии сурат.',
      );
      return null;
    }
  }

  Future<bool> save({
    String? name,
    String? nickname,
    String? phone,
    int? age,
    String? city,
    String? instagramUrl,
    String? whatsapp,
    String? photoUrl,
    bool? phoneVisible,
    bool? ageVisible,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.updateProfile(
        uid: uid,
        name: name,
        nickname: nickname,
        phone: phone,
        age: age,
        city: city,
        instagramUrl: instagramUrl,
        whatsapp: whatsapp,
        photoUrl: photoUrl,
        phoneVisible: phoneVisible,
        ageVisible: ageVisible,
      );
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Хатогии нигоҳдории профил.',
      );
      return false;
    }
  }
}

final editProfileControllerProvider = StateNotifierProvider.family<
    EditProfileController, EditProfileState, String>((ref, uid) {
  final repo = ref.watch(profileRepositoryProvider);
  return EditProfileController(repo, uid);
});
