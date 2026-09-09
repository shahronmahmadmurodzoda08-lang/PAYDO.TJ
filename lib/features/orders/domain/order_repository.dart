import '../../../models/order_model.dart';

abstract class OrderRepository {
  Future<String> createOrder(OrderModel order);

  /// Order-ҳои харидор (banди 11: "Customer бояд order history дошта бошад").
  Stream<List<OrderModel>> watchMyOrders(String customerId);

  /// Order-ҳое, ки дар онҳо ин seller/business маҳсулот дорад
  /// (banди 11: "Business owner бояд order-ҳоро бинад").
  Stream<List<OrderModel>> watchSellerOrders(String sellerId);

  Future<void> updateStatus({
    required String orderId,
    required OrderStatus status,
  });
}
