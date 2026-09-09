import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../../models/order_model.dart';
import '../domain/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection(FirestorePaths.orders);

  @override
  Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = await _ordersRef.add(order.toMap(isCreate: true));
      return docRef.id;
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии сохтани фармоиш: ${e.message}');
    }
  }

  @override
  Stream<List<OrderModel>> watchMyOrders(String customerId) {
    return _ordersRef
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => OrderModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Stream<List<OrderModel>> watchSellerOrders(String sellerId) {
    return _ordersRef
        .where('sellerIds', arrayContains: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => OrderModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<void> updateStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    try {
      await _ordersRef.doc(orderId).update({
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии навсозии ҳолати фармоиш: ${e.message}');
    }
  }
}
