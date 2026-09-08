import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../../models/user_model.dart';
import '../domain/auth_repository.dart';

/// Татбиқи воқеии AuthRepository бо Firebase Authentication (Google Sign-In)
/// ва Cloud Firestore барои сабти профили корбар.
///
/// Қарори тарроҳӣ (banди "агар ягон қарорро худат интихоб кунӣ, сабт кун"):
/// - Ҳангоми аввалин воридшавӣ бо Google, документи `users/{uid}` дар
///   Firestore танҳо ДАР СУРАТИ НАБУДАНАШ сохта мешавад (get-then-create),
///   то маълумоти тағйирдодаи корбар (масалан nickname) ҳангоми
///   воридшавии дубора аз байн наравад.
class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(FirestorePaths.users);

  @override
  UserModel? get currentUser {
    final u = _firebaseAuth.currentUser;
    if (u == null) return null;
    return UserModel.newFromGoogle(
      uid: u.uid,
      name: u.displayName ?? '',
      email: u.email ?? '',
      photoUrl: u.photoURL,
    );
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
      return _fetchOrCreateUserDoc(fbUser);
    });
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Корбар боксро бекор кард.
        throw const AuthFailure('Даровардан бекор карда шуд.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final fbUser = userCredential.user;
      if (fbUser == null) {
        throw const AuthFailure('Хатогии воридшавӣ рух дод.');
      }

      return _fetchOrCreateUserDoc(fbUser);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseAuthError(e));
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw const AuthFailure('Хатогии номаълум ҳангоми воридшавӣ рух дод.');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<UserModel> _fetchOrCreateUserDoc(fb.User fbUser) async {
    final docRef = _usersRef.doc(fbUser.uid);
    final snapshot = await docRef.get();

    if (snapshot.exists && snapshot.data() != null) {
      return UserModel.fromMap(fbUser.uid, snapshot.data()!);
    }

    final newUser = UserModel.newFromGoogle(
      uid: fbUser.uid,
      name: fbUser.displayName ?? '',
      email: fbUser.email ?? '',
      photoUrl: fbUser.photoURL,
    );

    await docRef.set(newUser.toMap(isCreate: true));
    return newUser;
  }

  String _mapFirebaseAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Интернет пайваст нест.';
      case 'account-exists-with-different-credential':
        return 'Ин почта аллакай бо усули дигар сабт шудааст.';
      case 'invalid-credential':
        return 'Маълумоти воридшавӣ нодуруст аст.';
      case 'user-disabled':
        return 'Ин ҳисоб бастааст.';
      default:
        return 'Хатогӣ рух дод. Лутфан аз нав кӯшиш кунед.';
    }
  }
}
