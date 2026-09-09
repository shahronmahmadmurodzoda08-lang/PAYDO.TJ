import 'dart:io';

import '../../../models/product_model.dart';

/// Domain layer барои идоракунии маҳсулот аз тарафи seller/business owner
/// (banди 6 спецификатсия). Аз `MarketplaceRepository` (PHASE 4) ҷудост,
/// зеро он барои "хондан"-и ҷамъиятӣ аст, ин феҳа барои "навиштан"-и
/// соҳиб — тақсимоти масъулият мутобиқи CQRS-и сабук.
abstract class ProductManagementRepository {
  /// Маҳсулоти худи корбар (ҳама, аз ҷумла hidden ва номавҷуд —
  /// барои "Идоракунии маҳсулот", на барои feed-и ҷамъиятӣ).
  Stream<List<ProductModel>> watchMyProducts(String sellerId);

  Future<String> addProduct(ProductModel product);

  Future<void> updateProduct(ProductModel product);

  Future<void> deleteProduct(String productId);

  Future<void> setHidden({required String productId, required bool isHidden});

  Future<void> updateQuantity({
    required String productId,
    required int quantity,
  });

  /// Боркунии як сурат аз галерея ба Storage, баргардонидани URL.
  /// Дар edit_product_screen барои ҳар сурат алоҳида даъват мешавад.
  Future<String> uploadProductImage({
    required String sellerId,
    required File imageFile,
  });

  Future<void> deleteProductImage(String imageUrl);
}
