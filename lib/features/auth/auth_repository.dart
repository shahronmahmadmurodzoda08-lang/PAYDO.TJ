import '../../../models/user_model.dart';

/// Domain layer — танҳо қарордод (contract). Ягон Firebase дар ин ҷо
/// зикр намешавад, то дар оянда provider-и auth-ро иваз кардан осон бошад.
abstract class AuthRepository {
  /// Ҷараёни зинда (stream)-и корбари ҳозира. null = ворид нашудааст.
  Stream<UserModel?> get authStateChanges;

  UserModel? get currentUser;

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();
}
