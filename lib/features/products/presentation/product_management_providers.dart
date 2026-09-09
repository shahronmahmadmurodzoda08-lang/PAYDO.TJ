import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product_model.dart';
import '../data/product_management_repository_impl.dart';
import '../domain/product_management_repository.dart';
import '../../auth/presentation/auth_providers.dart';

final productManagementRepositoryProvider =
    Provider<ProductManagementRepository>((ref) {
  return ProductManagementRepositoryImpl();
});

/// Маҳсулоти худи корбари ҷорӣ — барои экрани "Идоракунии маҳсулот".
final myProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  final repo = ref.watch(productManagementRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return repo.watchMyProducts(uid);
});

class ProductFormState {
  final bool isSaving;
  final bool isUploadingImage;
  final String? errorMessage;

  const ProductFormState({
    this.isSaving = false,
    this.isUploadingImage = false,
    this.errorMessage,
  });

  ProductFormState copyWith({
    bool? isSaving,
    bool? isUploadingImage,
    String? errorMessage,
  }) {
    return ProductFormState(
      isSaving: isSaving ?? this.isSaving,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      errorMessage: errorMessage,
    );
  }
}

class ProductFormController extends StateNotifier<ProductFormState> {
  final ProductManagementRepository _repository;

  ProductFormController(this._repository) : super(const ProductFormState());

  Future<String?> uploadImage({
    required String sellerId,
    required dynamic imageFile,
  }) async {
    state = state.copyWith(isUploadingImage: true, errorMessage: null);
    try {
      final url = await _repository.uploadProductImage(
        sellerId: sellerId,
        imageFile: imageFile,
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

  Future<bool> saveNew(ProductModel product) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.addProduct(product);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Хатогии сабт.');
      return false;
    }
  }

  Future<bool> saveEdit(ProductModel product) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.updateProduct(product);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Хатогии сабт.');
      return false;
    }
  }

  Future<void> delete(String productId) =>
      _repository.deleteProduct(productId);

  Future<void> setHidden(String productId, bool isHidden) =>
      _repository.setHidden(productId: productId, isHidden: isHidden);

  Future<void> updateQuantity(String productId, int quantity) =>
      _repository.updateQuantity(productId: productId, quantity: quantity);
}

final productFormControllerProvider =
    StateNotifierProvider<ProductFormController, ProductFormState>((ref) {
  final repo = ref.watch(productManagementRepositoryProvider);
  return ProductFormController(repo);
});
