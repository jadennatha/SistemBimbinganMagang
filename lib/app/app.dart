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

      // untuk produksi
      // initialRoute: Routes.splash,

      // kalau mau tes tampilan dosen:
      initialRoute: Routes.dosenLogbook,
      routes: Routes.map,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final width = media.size.width;

        const baseWidth = 375.0;
        double scale = width / baseWidth;

        // batasi supaya tidak terlalu besar atau kecil
        scale = scale.clamp(0.95, 1.2).toDouble();

        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(scale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blueBook,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'StackSansText',
    );

    final t = base.textTheme;

    final patchedTextTheme = t.copyWith(
      headlineLarge: t.headlineLarge?.copyWith(
        fontFamily: 'StackSansHeadline',
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      ),
      headlineMedium: t.headlineMedium?.copyWith(
        fontFamily: 'StackSansHeadline',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      ),
      titleLarge: t.titleLarge?.copyWith(
        fontFamily: 'StackSansHeadline',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      ),
      titleMedium: t.titleMedium?.copyWith(
        fontFamily: 'StackSansHeadline',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.navyDark,
      ),
      bodyLarge: t.bodyLarge?.copyWith(
        fontFamily: 'StackSansText',
        fontSize: 16,
        color: AppColors.navyDark,
      ),
      bodyMedium: t.bodyMedium?.copyWith(
        fontFamily: 'StackSansText',
        fontSize: 15,
        color: AppColors.navyDark,
      ),
      bodySmall: t.bodySmall?.copyWith(
        fontFamily: 'StackSansText',
        fontSize: 13,
        color: AppColors.blueGrey,
      ),
      labelSmall: t.labelSmall?.copyWith(
        fontFamily: 'StackSansText',
        fontSize: 11,
        color: AppColors.blueGrey,
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
          textStyle: patchedTextTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
