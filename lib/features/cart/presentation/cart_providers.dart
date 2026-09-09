import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/cart_item_model.dart';
import '../../../models/product_model.dart';
import '../data/cart_repository.dart';

final cartRepositoryProvider = Provider((ref) => CartRepository());

/// Нархи собити доставка (banди 25: соддатарин ҳал барои MVP — free
/// tier, бе интегратсияи мураккаб бо ҳисоби масофа). Дар PHASE 12/14
/// (Delivery/Live Tracking) метавонад аз рӯи масофа/бизнес ҳисоб шавад.
const double kFlatDeliveryFee = 15.0;

class CartController extends StateNotifier<List<CartItemModel>> {
  final CartRepository _repository;

  CartController(this._repository) : super(const []) {
    _load();
  }

  Future<void> _load() async {
    state = await _repository.loadCart();
  }

  Future<void> _persist() => _repository.saveCart(state);

  double get subtotal => state.fold(0, (sum, item) => sum + item.subtotal);
  int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);

  Future<void> addProduct(ProductModel product, {int quantity = 1}) async {
    final index = state.indexWhere((i) => i.productId == product.id);
    if (index != -1) {
      final existing = state[index];
      final newQty = (existing.quantity + quantity)
          .clamp(1, product.quantity == 0 ? 1 : product.quantity);
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == index)
            CartItemModel(
              productId: existing.productId,
              productName: existing.productName,
              productImage: existing.productImage,
              price: existing.price,
              sellerId: existing.sellerId,
              businessId: existing.businessId,
              availableQuantity: existing.availableQuantity,
              quantity: newQty,
            )
          else
            state[i],
      ];
    } else {
      state = [
        ...state,
        CartItemModel(
          productId: product.id,
          productName: product.name,
          productImage: product.primaryImage,
          price: product.price,
          sellerId: product.sellerId,
          businessId: product.businessId,
          availableQuantity: product.quantity,
          quantity: quantity.clamp(1, product.quantity),
        ),
      ];
    }
    await _persist();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      return removeProduct(productId);
    }
    state = [
      for (final item in state)
        if (item.productId == productId)
          CartItemModel(
            productId: item.productId,
            productName: item.productName,
            productImage: item.productImage,
            price: item.price,
            sellerId: item.sellerId,
            businessId: item.businessId,
            availableQuantity: item.availableQuantity,
            quantity: quantity.clamp(1, item.availableQuantity == 0 ? 1 : item.availableQuantity),
          )
        else
          item,
    ];
    await _persist();
  }

  Future<void> removeProduct(String productId) async {
    state = state.where((i) => i.productId != productId).toList();
    await _persist();
  }

  Future<void> clear() async {
    state = const [];
    await _repository.clearCart();
  }
}

final cartControllerProvider =
    StateNotifierProvider<CartController, List<CartItemModel>>((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  return CartController(repo);
});

final cartSubtotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartControllerProvider);
  return items.fold(0, (sum, item) => sum + item.subtotal);
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartControllerProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});
