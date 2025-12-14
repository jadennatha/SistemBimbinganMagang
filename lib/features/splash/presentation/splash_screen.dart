import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../../app/routes.dart';
import '../../auth/data/auth_provider.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../mahasiswa/presentation/home_screen.dart';
import '../../pembimbing/presentation/dosen_home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _logoScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 1.0, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goNext();
      }
    });

    _controller.forward();
  }

  Future<void> _goNext() async {
    final authProvider = context.read<AuthProvider>();

    if (!mounted) return;

    final Widget targetPage;
    final String targetName;

    if (!authProvider.isAuthenticated) {
      // Belum login → ke onboarding
      targetPage = const OnboardingScreen();
      targetName = Routes.onboarding;
    } else {
      // Sudah login → fetch role dulu, lalu arahkan sesuai role
      await authProvider.fetchUserRole();

      if (authProvider.isDosenOrMentor) {
        targetPage = const DosenHomeShell();
        targetName = Routes.dosenHome;
      } else {
        targetPage = const HomeScreen();
        targetName = Routes.home;
      }
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        settings: RouteSettings(name: targetName),
        pageBuilder: (context, animation, secondaryAnimation) => targetPage,
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06), // sedikit naik dari bawah
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    width: 140, // Diperbesar dari 120
                    height: 140,
                    decoration: const BoxDecoration(
                      color: AppColors.navy,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22), // Padding disesuaikan
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'E - BIMA', // Update teks
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center, // Ratakan tengah
              ),
              const SizedBox(height: 8),
              Text(
                'Monitoring Bimbingan Magang', // Update teks
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.blueGrey,
                ),
                textAlign: TextAlign.center, // Ratakan tengah
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 180,
                height: 4,
                child: AnimatedBuilder(
                  animation: _progress,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: _progress.value,
                        color: AppColors.white,
                        backgroundColor: AppColors.navy.withOpacity(0.4),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24), // Jarak diperbesar dari 12
              Text(
                'Menyiapkan Sistem...', // Update teks
                style: textTheme.bodySmall?.copyWith(color: AppColors.blueGrey),
                textAlign: TextAlign.center, // Ratakan tengah
              ),
            ],
          ),
        ),
      ),
    );
  }
}
