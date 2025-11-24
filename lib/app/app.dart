import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Bimbingan Magang',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: Routes.splash,
      routes: Routes.map,
    );
  }

  ThemeData _buildTheme() {
    // Tema dasar
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blueBook,
        brightness: Brightness.dark,
      ),
      // Semua scaffold pakai warna ini
      scaffoldBackgroundColor: AppColors.background,
      // Body text pakai StackSansText
      fontFamily: 'StackSansText',
    );

    final textTheme = base.textTheme;

    // Heading pakai StackSansHeadline
    final patchedTextTheme = textTheme.copyWith(
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontFamily: 'StackSansHeadline',
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontFamily: 'StackSansHeadline',
        fontWeight: FontWeight.w700,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontFamily: 'StackSansHeadline',
        fontWeight: FontWeight.w700,
      ),
    );

    return base.copyWith(
      textTheme: patchedTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: patchedTextTheme.titleLarge?.copyWith(
          color: AppColors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueBook,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
