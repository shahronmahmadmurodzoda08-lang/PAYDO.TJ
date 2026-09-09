import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../../models/business_model.dart';
import '../../../models/product_model.dart';
import '../domain/business_repository.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  BusinessRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _businessesRef =>
      _firestore.collection(FirestorePaths.businesses);

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection(FirestorePaths.products);

  @override
  Stream<BusinessModel?> watchBusinessByOwner(String ownerId) {
    return _businessesRef.doc(ownerId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return BusinessModel.fromMap(snap.id, snap.data()!);
    });
  }

  @override
  Future<BusinessModel?> getBusinessByOwner(String ownerId) async {
    final snap = await _businessesRef.doc(ownerId).get();
    if (!snap.exists || snap.data() == null) return null;
    return BusinessModel.fromMap(snap.id, snap.data()!);
  }

  @override
  Future<BusinessModel> getBusiness(String businessId) async {
    final snap = await _businessesRef.doc(businessId).get();
    if (!snap.exists || snap.data() == null) {
      throw const ServerFailure('Бизнес ёфт нашуд.');
    }
    return BusinessModel.fromMap(snap.id, snap.data()!);
  }

  @override
  Future<String> uploadBusinessImage({
    required String ownerId,
    required File imageFile,
    required bool isLogo,
  }) async {
    try {
      final fileName = isLogo ? 'logo.jpg' : 'cover.jpg';
      final ref = _storage.ref().child('business_images/$ownerId/$fileName');
      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии боркунии сурат: ${e.message}');
    }
  }

  @override
  Future<void> createOrUpdateBusiness(BusinessModel business) async {
    final docRef = _businessesRef.doc(business.ownerId);
    final existing = await docRef.get();
    final isCreate = !existing.exists;

    try {
      await docRef.set(
        business.toMap(isCreate: isCreate),
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии нигоҳдории бизнес: ${e.message}');
    }
  }

  @override
  Stream<List<ProductModel>> watchBusinessProducts(String businessId) {
    return _productsRef
        .where('businessId', isEqualTo: businessId)
        .where('isHidden', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ProductModel.fromMap(d.id, d.data())).toList());
  }
}
