import 'dart:io';

import '../../../models/business_model.dart';
import '../../../models/product_model.dart';

/// Domain layer барои Business.
///
/// Қарори тарроҳӣ (сабт мутобиқи banди умумии спецификатсия): дар MVP
/// ҳар корбар ҳадди аксар ЯК Business Profile дошта метавонад, ва
/// document id-и `businesses/{id}` баробар ба `ownerId` (= uid) аст.
/// Ин имкон медиҳад "оё ин корбар бизнес дорад?" бе query иловагӣ,
/// танҳо бо `get(uid)` санҷида шавад. Агар дар оянда якчанд бизнес
/// барои як корбар лозим шавад (масалан якчанд филиал), ин ба auto-id
/// бо майдони алоҳидаи index иваз карда мешавад — бе вайрон кардани
/// UI, зеро ҳама ҷо аз рӯи `businessId` кор мекунад, на аз рӯи uid.
abstract class BusinessRepository {
  Stream<BusinessModel?> watchBusinessByOwner(String ownerId);

  Future<BusinessModel?> getBusinessByOwner(String ownerId);

  Future<BusinessModel> getBusiness(String businessId);

  Future<String> uploadBusinessImage({
    required String ownerId,
    required File imageFile,
    required bool isLogo, // true=logo, false=cover
  });

  Future<void> createOrUpdateBusiness(BusinessModel business);

  /// Маҳсулоти ин бизнес — барои таби "Products" дар бизнес-профил.
  Stream<List<ProductModel>> watchBusinessProducts(String businessId);
}
