import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/business_model.dart';
import '../../../models/product_model.dart';
import '../../../models/user_model.dart';
import '../data/business_repository_impl.dart';
import '../domain/business_repository.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepositoryImpl();
});

/// Бизнеси корбари ҷорӣ (агар дошта бошад) — real-time.
/// null маънои онро дорад, ки корбар ҳанӯз бизнес накушодааст.
final myBusinessProvider = StreamProvider<BusinessModel?>((ref) {
  final repo = ref.watch(businessRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(null);
  return repo.watchBusinessByOwner(uid);
});

final businessByIdProvider =
    FutureProvider.family<BusinessModel, String>((ref, businessId) {
  final repo = ref.watch(businessRepositoryProvider);
  return repo.getBusiness(businessId);
});

final businessProductsProvider =
    StreamProvider.family<List<ProductModel>, String>((ref, businessId) {
  final repo = ref.watch(businessRepositoryProvider);
  return repo.watchBusinessProducts(businessId);
});

class SaveBusinessState {
  final bool isSaving;
  final bool isUploadingImage;
  final String? errorMessage;

  const SaveBusinessState({
    this.isSaving = false,
    this.isUploadingImage = false,
    this.errorMessage,
  });

  SaveBusinessState copyWith({
    bool? isSaving,
    bool? isUploadingImage,
    String? errorMessage,
  }) {
    return SaveBusinessState(
      isSaving: isSaving ?? this.isSaving,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      errorMessage: errorMessage,
    );
  }
}

class SaveBusinessController extends StateNotifier<SaveBusinessState> {
  final BusinessRepository _repository;
  final Ref _ref;

  SaveBusinessController(this._repository, this._ref)
      : super(const SaveBusinessState());

  Future<String?> uploadImage({
    required String ownerId,
    required dynamic imageFile, // File — dart:io, генералӣ нигоҳ дошта шуд
    required bool isLogo,
  }) async {
    state = state.copyWith(isUploadingImage: true, errorMessage: null);
    try {
      final url = await _repository.uploadBusinessImage(
        ownerId: ownerId,
        imageFile: imageFile,
        isLogo: isLogo,
      );
      state = state.copyWith(isUploadingImage: false);
      return url;
    } catch (e) {
      state = state.copyWith(
        isUploadingImage: false,
        errorMessage: 'Хатогии боркунии сурат.',
      );
      return null;
    }
  }

  Future<bool> save(BusinessModel business) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.createOrUpdateBusiness(business);

      // Пас аз кушодани/навсозии бизнес, ба accountTypes-и корбар
      // 'business' илова мешавад (banди 15 спецификатсия), то дар
      // оянда UI/Security Rules фарқ гузошта тавонанд байни оддӣ
      // user ва business owner. Агар аллакай дошта бошад, такрор
      // илова намешавад.
      final currentUser =
          await _ref.read(profileRepositoryProvider).getUser(business.ownerId);
      if (!currentUser.accountTypes.contains(AccountType.business)) {
        await _ref.read(profileRepositoryProvider).updateProfile(
              uid: business.ownerId,
              accountTypes: [
                ...currentUser.accountTypes,
                AccountType.business,
              ],
            );
      }

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Хатогии нигоҳдории бизнес.',
      );
      return false;
    }
  }
}

final saveBusinessControllerProvider =
    StateNotifierProvider<SaveBusinessController, SaveBusinessState>((ref) {
  final repo = ref.watch(businessRepositoryProvider);
  return SaveBusinessController(repo, ref);
});
