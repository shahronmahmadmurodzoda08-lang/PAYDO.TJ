import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../../models/user_model.dart';
import '../domain/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProfileRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(FirestorePaths.users).doc(uid);

  @override
  Stream<UserModel> watchUser(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        throw const ServerFailure('Профил ёфт нашуд.');
      }
      return UserModel.fromMap(uid, snap.data()!);
    });
  }

  @override
  Future<UserModel> getUser(String uid) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists || snap.data() == null) {
      throw const ServerFailure('Профил ёфт нашуд.');
    }
    return UserModel.fromMap(uid, snap.data()!);
  }

  @override
  Future<String> uploadProfilePhoto({
    required String uid,
    required File imageFile,
    String? oldPhotoUrl,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child('profile_photos')
          .child('$uid.jpg');

      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();

      // Қарори тарроҳӣ: мо ҳамеша дар роҳи собит `profile_photos/{uid}.jpg`
      // менависем (на файли нав ҳар дафъа), то сурати кӯҳна худкор иваз
      // шавад ва фазои Storage-и ройгон (banди 25) беҳуда пур нашавад.
      return url;
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии боркунии сурат: ${e.message}');
    }
  }

  @override
  Future<void> updateProfile({
    required String uid,
    String? name,
    String? nickname,
    String? phone,
    int? age,
    String? city,
    String? instagramUrl,
    String? whatsapp,
    String? photoUrl,
    bool? phoneVisible,
    bool? ageVisible,
  }) async {
    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) data['name'] = name;
    if (nickname != null) data['nickname'] = nickname;
    if (phone != null) data['phone'] = phone;
    if (age != null) data['age'] = age;
    if (city != null) data['city'] = city;
    if (instagramUrl != null) data['instagramUrl'] = instagramUrl;
    if (whatsapp != null) data['whatsapp'] = whatsapp;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (phoneVisible != null) data['phoneVisible'] = phoneVisible;
    if (ageVisible != null) data['ageVisible'] = ageVisible;

    try {
      await _userDoc(uid).update(data);
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии навсозии профил: ${e.message}');
    }
  }
}
