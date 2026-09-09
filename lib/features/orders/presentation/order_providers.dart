import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/order_model.dart';
import '../data/order_repository_impl.dart';
import '../domain/order_repository.dart';
import '../../auth/presentation/auth_providers.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl();
});

final myOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return repo.watchMyOrders(uid);
});

final sellerOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return repo.watchSellerOrders(uid);
});

class CheckoutState {
  final bool isSubmitting;
  final String? errorMessage;

  const CheckoutState({this.isSubmitting = false, this.errorMessage});

  CheckoutState copyWith({bool? isSubmitting, String? errorMessage}) =>
      CheckoutState(
        isSubmitting: isSubmitting ?? this.isSubmitting,
        errorMessage: errorMessage,
      );
}

class CheckoutController extends StateNotifier<CheckoutState> {
  final OrderRepository _repository;

  CheckoutController(this._repository) : super(const CheckoutState());

  Future<String?> submit(OrderModel order) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final id = await _repository.createOrder(order);
      state = state.copyWith(isSubmitting: false);
      return id;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Хатогии сохтани фармоиш.',
      );
      return null;
    }
  }
}

final checkoutControllerProvider =
    StateNotifierProvider<CheckoutController, CheckoutState>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return CheckoutController(repo);
});

final orderStatusUpdateProvider =
    Provider<Future<void> Function(String orderId, OrderStatus status)>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return (orderId, status) => repo.updateStatus(orderId: orderId, status: status);
});
