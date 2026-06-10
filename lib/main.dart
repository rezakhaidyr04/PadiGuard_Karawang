// Use this entrypoint for Flutlab to avoid mismatch with pubspec and native-disabled features.
// If you want normal native build, you can revert this file and use lib/main_flutlab.dart accordingly.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/dashboard_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PadiGuard Karawang',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/splash': (context) => const SplashScreen(),
      },
      builder: (context, child) {
        return child ?? const Placeholder();
      },
    );
  }
}
