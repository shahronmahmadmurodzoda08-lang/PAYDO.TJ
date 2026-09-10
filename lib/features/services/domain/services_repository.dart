import '../../../models/service_order_model.dart';
import '../../../models/service_provider_model.dart';

abstract class ServicesRepository {
  Stream<List<ServiceProviderModel>> watchProviders({String? category, String? city});
  Stream<ServiceProviderModel?> watchMyProviderProfile(String uid);
  Future<ServiceProviderModel?> getProvider(String uid);
  Future<void> saveProviderProfile(ServiceProviderModel provider);

  Future<void> createOrder(ServiceOrderModel order);
  Stream<List<ServiceOrderModel>> watchMyOrders(String customerId);
  Stream<List<ServiceOrderModel>> watchProviderOrders(String providerId);
  Future<void> updateOrderStatus({
    required String orderId,
    required ServiceOrderStatus status,
  });
}
