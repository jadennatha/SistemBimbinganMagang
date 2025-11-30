import 'package:flutter/material.dart';

import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/dosen/presentation/logbook_validation_list_screen.dart';

class Routes {
  Routes._();

  // nama route
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String dosenLogbook = '/dosen/logbook';

  // peta route untuk MaterialApp.routes
  static Map<String, WidgetBuilder> get map => {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    dosenLogbook: (context) => const LogbookValidationListScreen(),
  };
}
