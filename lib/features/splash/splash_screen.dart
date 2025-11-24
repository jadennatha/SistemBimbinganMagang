import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../onboarding/onboarding_screen.dart';
import '../home/home_screen.dart';

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
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    final Widget targetPage;
    final String targetName;

    if (user == null) {
      targetPage = const OnboardingScreen(); // kalau belum login
      targetName = Routes.onboarding;
    } else {
      targetPage = const HomeScreen(); // di sini berisi dashboard_content
      targetName = Routes.home;
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
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: AppColors.navy,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Image.asset(
                        'assets/images/logo.png', // sesuaikan path logo
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'E Bimbingan',
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Monitoring bimbingan magang',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.blueGrey,
                ),
                textAlign: TextAlign.center,
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
                        value: _progress.value, // 0 sampai 1
                        color: AppColors.white, // bar putih
                        backgroundColor: AppColors.navy.withOpacity(
                          0.4,
                        ), // track tipis
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Menyiapkan Sistem..',
                style: textTheme.bodySmall?.copyWith(color: AppColors.blueGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
