import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import 'dashboard_content.dart';
import 'logbook_content.dart';
import 'profile_content.dart';
import 'floating_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Area konten yang bisa discroll
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Card(
                      color: AppColors.surfaceLight,
                      elevation: 10,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slide,
                              child: child,
                            ),
                          );
                        },
                        child: ConstrainedBox(
                          key: ValueKey<int>(_currentIndex),
                          constraints: const BoxConstraints(
                            minHeight: 420, // tinggi minimum sama di semua tab
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(32, 24, 32, 28),
                            child: _buildTabContent(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Navbar tetap di bawah layar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: FloatingNavBar(
                currentIndex: _currentIndex,
                onChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return const DashboardContent();
      case 1:
        return const LogbookContent();
      case 2:
      default:
        return const ProfileContent();
    }
  }
}
