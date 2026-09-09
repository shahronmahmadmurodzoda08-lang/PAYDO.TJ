import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';
// Пас аз иҷрои `flutterfire configure` ин файл худкор сохта мешавад:
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // баъд аз flutterfire configure фаъол кунед
  );

  runApp(const ProviderScope(child: PaydoApp()));
}

class PaydoApp extends ConsumerWidget {
  const PaydoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
