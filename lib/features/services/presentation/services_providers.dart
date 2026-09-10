import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/service_order_model.dart';
import '../../../models/service_provider_model.dart';
import '../data/services_repository_impl.dart';
import '../domain/services_repository.dart';
import '../../auth/presentation/auth_providers.dart';

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepositoryImpl();
});

class ServicesFilter {
  final String? category;
  final String? city;
  const ServicesFilter({this.category, this.city});

  ServicesFilter copyWith({
    String? category,
    bool clearCategory = false,
    String? city,
    bool clearCity = false,
  }) {
    return ServicesFilter(
      category: clearCategory ? null : (category ?? this.category),
      city: clearCity ? null : (city ?? this.city),
    );
  }
}

class ServicesFilterNotifier extends StateNotifier<ServicesFilter> {
  ServicesFilterNotifier() : super(const ServicesFilter());

  void setCategory(String? c) =>
      state = c == null ? state.copyWith(clearCategory: true) : state.copyWith(category: c);
  void setCity(String? c) =>
      state = c == null ? state.copyWith(clearCity: true) : state.copyWith(city: c);
}

final servicesFilterProvider =
    StateNotifierProvider<ServicesFilterNotifier, ServicesFilter>(
  (ref) => ServicesFilterNotifier(),
);

final providersListProvider = StreamProvider<List<ServiceProviderModel>>((ref) {
  final repo = ref.watch(servicesRepositoryProvider);
  final filter = ref.watch(servicesFilterProvider);
  return repo.watchProviders(category: filter.category, city: filter.city);
});

final myProviderProfileProvider = StreamProvider<ServiceProviderModel?>((ref) {
  final repo = ref.watch(servicesRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(null);
  return repo.watchMyProviderProfile(uid);
});

final providerDetailsProvider =
    FutureProvider.family<ServiceProviderModel?, String>((ref, uid) {
  final repo = ref.watch(servicesRepositoryProvider);
  return repo.getProvider(uid);
});

final myServiceOrdersProvider = StreamProvider<List<ServiceOrderModel>>((ref) {
  final repo = ref.watch(servicesRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return repo.watchMyOrders(uid);
});

final providerServiceOrdersProvider = StreamProvider<List<ServiceOrderModel>>((ref) {
  final repo = ref.watch(servicesRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return repo.watchProviderOrders(uid);
});

class ServicesActionState {
  final bool isSaving;
  final String? errorMessage;
  const ServicesActionState({this.isSaving = false, this.errorMessage});

  ServicesActionState copyWith({bool? isSaving, String? errorMessage}) =>
      ServicesActionState(isSaving: isSaving ?? this.isSaving, errorMessage: errorMessage);
}

class ServicesActionController extends StateNotifier<ServicesActionState> {
  final ServicesRepository _repository;
  ServicesActionController(this._repository) : super(const ServicesActionState());

  Future<bool> saveProfile(ServiceProviderModel provider) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.saveProviderProfile(provider);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Хатогии сабт.');
      return false;
    }
  }

  Future<bool> createOrder(ServiceOrderModel order) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.createOrder(order);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Хатогии фиристодани фармоиш.');
      return false;
    }
  }

  Future<void> updateOrderStatus(String orderId, ServiceOrderStatus status) =>
      _repository.updateOrderStatus(orderId: orderId, status: status);
}

final servicesActionControllerProvider =
    StateNotifierProvider<ServicesActionController, ServicesActionState>((ref) {
  final repo = ref.watch(servicesRepositoryProvider);
  return ServicesActionController(repo);
});
