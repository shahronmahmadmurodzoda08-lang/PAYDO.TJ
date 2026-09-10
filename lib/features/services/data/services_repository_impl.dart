import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../../models/service_order_model.dart';
import '../../../models/service_provider_model.dart';
import '../domain/services_repository.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final FirebaseFirestore _firestore;

  ServicesRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _providersRef =>
      _firestore.collection(FirestorePaths.services);

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection(FirestorePaths.serviceOrders);

  @override
  Stream<List<ServiceProviderModel>> watchProviders({String? category, String? city}) {
    Query<Map<String, dynamic>> query = _providersRef.where('isVisible', isEqualTo: true);
    if (category != null) {
      query = query.where('serviceCategory', isEqualTo: category);
    }
    if (city != null) {
      query = query.where('city', isEqualTo: city);
    }
    query = query.orderBy('createdAt', descending: true).limit(50);

    return query.snapshots().map((snap) =>
        snap.docs.map((d) => ServiceProviderModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Stream<ServiceProviderModel?> watchMyProviderProfile(String uid) {
    return _providersRef.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return ServiceProviderModel.fromMap(snap.id, snap.data()!);
    });
  }

  @override
  Future<ServiceProviderModel?> getProvider(String uid) async {
    final snap = await _providersRef.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return ServiceProviderModel.fromMap(snap.id, snap.data()!);
  }

  @override
  Future<void> saveProviderProfile(ServiceProviderModel provider) async {
    final docRef = _providersRef.doc(provider.uid);
    final existing = await docRef.get();
    try {
      await docRef.set(
        provider.toMap(isCreate: !existing.exists),
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии нигоҳдории профили хизматрасон: ${e.message}');
    }
  }

  @override
  Future<void> createOrder(ServiceOrderModel order) async {
    try {
      await _ordersRef.add(order.toMap(isCreate: true));
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии фиристодани фармоиш: ${e.message}');
    }
  }

  @override
  Stream<List<ServiceOrderModel>> watchMyOrders(String customerId) {
    return _ordersRef
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ServiceOrderModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Stream<List<ServiceOrderModel>> watchProviderOrders(String providerId) {
    return _ordersRef
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ServiceOrderModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required ServiceOrderStatus status,
  }) async {
    await _ordersRef.doc(orderId).update({
      'status': status.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
