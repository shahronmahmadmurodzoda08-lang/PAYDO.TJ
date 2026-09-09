import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/root_shell.dart';
import '../features/profile/presentation/profile_screen.dart';

/// Роҳҳои (routes) барномаро дар як ҷой нигоҳ медорем, то ҳангоми
/// иловаи феча (Marketplace, Jobs, ...) танҳо дар ин файл роҳи нав
/// илова карда шавад ва набояд бо Navigator.push ҳар ҷо paths hardcode шавад.
class AppRoutes {
  AppRoutes._();
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const profile = '/profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: _AuthRefreshNotifier(ref),
    redirect: (context, state) {
      // То ҳолати Auth (Firebase) бор нашавад, дар splash интизор мешавем.
      final isLoading = authState.isLoading && !authState.hasValue;
      if (isLoading) return null;

      final isLoggedIn = authState.value != null;
      final goingToLogin = state.matchedLocation == AppRoutes.login;

      if (!isLoggedIn && !goingToLogin) return AppRoutes.login;
      if (isLoggedIn &&
          (goingToLogin || state.matchedLocation == AppRoutes.splash)) {
        return AppRoutes.home;
      }
      if (!isLoggedIn && state.matchedLocation == AppRoutes.splash) {
        return AppRoutes.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const RootShell(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

/// go_router на ба таври худкор ба Riverpod StreamProvider гӯш медиҳад —
/// ин Listenable-и хурд тағйиротро ба GoRouter мерасонад, то redirect
/// дар ҳар тағйири authState аз нав арзёбӣ шавад.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
