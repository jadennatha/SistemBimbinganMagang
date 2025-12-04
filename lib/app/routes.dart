import 'package:flutter/material.dart';

import '../features/splash/presentation/splash_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/dosen/presentation/dosen_home_shell.dart';

class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/home';

  // route untuk dosen
  static const dosenHome = '/dosen';

  static Map<String, WidgetBuilder> get map => {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),

    // ini yang dipakai untuk tampilan dosen
    dosenHome: (context) => const DosenHomeShell(),
  };
}
