import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/product_model.dart';
import '../data/marketplace_repository_impl.dart';
import '../domain/marketplace_repository.dart';
import '../../auth/presentation/auth_providers.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepositoryImpl();
});

/// Filter-и ҷориро нигоҳ медорад (category chip-и интихобшуда ва ғайра).
class ProductFilterNotifier extends StateNotifier<ProductFilter> {
  ProductFilterNotifier() : super(const ProductFilter());

  void setCategory(String? category) {
    state = category == null
        ? state.copyWith(clearCategory: true)
        : state.copyWith(category: category);
  }

  void setCity(String? city) {
    state = city == null
        ? state.copyWith(clearCity: true)
        : state.copyWith(city: city);
  }
}

final productFilterProvider =
    StateNotifierProvider<ProductFilterNotifier, ProductFilter>(
  (ref) => ProductFilterNotifier(),
);

/// Рӯйхати маҳсулот дар асоси filter-и ҷорӣ.
final productListProvider = StreamProvider<List<ProductModel>>((ref) {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final filter = ref.watch(productFilterProvider);
  return repo.watchProducts(filter);
});

final productDetailsProvider =
    FutureProvider.family<ProductModel, String>((ref, productId) {
  final repo = ref.watch(marketplaceRepositoryProvider);
  return repo.getProduct(productId);
});

/// ID-ҳои favorite-и корбари ҷорӣ (агар ворид нашуда бошад — маҷмӯи холӣ).
final favoriteIdsProvider = StreamProvider<Set<String>>((ref) {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const {});
  return repo.watchFavoriteIds(uid);
});

final toggleFavoriteProvider =
    Provider<Future<void> Function(String productId, bool isFavorite)>((ref) {
  final repo = ref.watch(marketplaceRepositoryProvider);
  return (productId, isFavorite) {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return Future.value();
    return repo.toggleFavorite(
      uid: uid,
      productId: productId,
      isFavorite: isFavorite,
    );
  };
});
