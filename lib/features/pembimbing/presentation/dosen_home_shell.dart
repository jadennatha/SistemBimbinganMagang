import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../auth/data/auth_provider.dart';
import 'dosen_floating_navbar.dart';
import 'dosen_main_screen.dart';
import 'dosen_history_screen.dart';
import 'dosen_profile_screen.dart';

class DosenHomeShell extends StatefulWidget {
  const DosenHomeShell({super.key});

  @override
  State<DosenHomeShell> createState() => _DosenHomeShellState();
}

class _DosenHomeShellState extends State<DosenHomeShell> {
  int _currentIndex = 0;

  void _onNavChanged(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return DosenMainScreen(onProfileTap: () => _onNavChanged(2));
      case 1:
        return const DosenHistoryScreen();
      case 2:
      default:
        return const DosenProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isMentor = authProvider.isMentor;

    return Scaffold(
      backgroundColor: AppColors.background,
      // AnimatedSwitcher for smooth tab transitions
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _buildCurrentPage(),
        ),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
      // navbar melayang di bawah
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: DosenFloatingNavbar(
            currentIndex: _currentIndex,
            onChanged: _onNavChanged,
            isMentor: isMentor,
          ),
        ),
      ),
    );
  }
}
