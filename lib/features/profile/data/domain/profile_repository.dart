import 'dart:io';

import '../../../models/user_model.dart';

/// Domain layer барои Profile — бе истинод ба Firebase бевосита.
abstract class ProfileRepository {
  /// Ҷараёни зиндаи маълумоти профили корбари ҷорӣ (барои экрани Profile).
  Stream<UserModel> watchUser(String uid);

  Future<UserModel> getUser(String uid);

  /// Бор кардани сурат аз галерея ба Storage ва баргардонидани URL-и он.
  /// `oldPhotoUrl` агар дода шавад ва аз Storage-и худи мо бошад, нест
  /// карда мешавад, то фазо беҳуда пур нашавад (banди 25 — free tier).
  Future<String> uploadProfilePhoto({
    required String uid,
    required File imageFile,
    String? oldPhotoUrl,
  });

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
  });
}
