import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user_model.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';

/// Repository-и Auth (як marotaba сохта мешавад, дар тамоми app истифода мешавад).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Ҷараёни зиндаи ҳолати воридшавӣ — router (Phase 0 routing) ва
/// UI-и дигар ба ин гӯш медиҳанд, то Splash → Login → Home худкор кор кунад.
final authStateProvider = StreamProvider<UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

/// Controller барои амали "Sign in with Google" — AsyncValue ба UI имкон
/// медиҳад loading/error-ро бе бойлерплейти иловагӣ идора кунад.
class SignInController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // holатi ибтидоӣ — коре намекунад.
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() => repo.signInWithGoogle());
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
  }
}

final signInControllerProvider =
    AsyncNotifierProvider<SignInController, void>(SignInController.new);
