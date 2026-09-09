import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/cart_item_model.dart';

/// Сабад дар device нигоҳ дошта мешавад (SharedPreferences, JSON).
/// Ниг. эзоҳи тарроҳӣ дар `lib/models/cart_item_model.dart`.
class CartRepository {
  static const _storageKey = 'paydo_cart_items';

  Future<List<CartItemModel>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => CartItemModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCart(List<CartItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, raw);
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
