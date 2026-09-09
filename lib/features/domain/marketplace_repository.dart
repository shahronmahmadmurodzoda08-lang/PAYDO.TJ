import '../../../models/product_model.dart';

/// Filter-ҳои ҷустуҷӯ/навигатсия дар Marketplace (banди 4 ва 17).
class ProductFilter {
  final String? category;
  final String? city;
  final bool onlyAvailable;

  const ProductFilter({
    this.category,
    this.city,
    this.onlyAvailable = true,
  });

  ProductFilter copyWith({
    String? category,
    bool clearCategory = false,
    String? city,
    bool clearCity = false,
    bool? onlyAvailable,
  }) {
    return ProductFilter(
      category: clearCategory ? null : (category ?? this.category),
      city: clearCity ? null : (city ?? this.city),
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
    );
  }
}

abstract class MarketplaceRepository {
  /// Рӯйхати маҳсулот бо filter (category/city) — real-time stream.
  Stream<List<ProductModel>> watchProducts(ProductFilter filter);

  Future<ProductModel> getProduct(String productId);

  /// Favorites — banди 8: "favorite" барои корбар.
  Stream<Set<String>> watchFavoriteIds(String uid);

  Future<void> toggleFavorite({
    required String uid,
    required String productId,
    required bool isFavorite,
  });
}
