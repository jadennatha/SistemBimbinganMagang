import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/widgets/shared_floating_navbar.dart';

import 'dosen_main_screen.dart';
import 'dosen_history_screen.dart';
import 'dosen_profile_screen.dart';

class DosenHomeShell extends StatefulWidget {
  const DosenHomeShell({super.key});

  @override
  State<DosenHomeShell> createState() => _DosenHomeShellState();
}

class _DosenHomeShellState extends State<DosenHomeShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // Cache pages to avoid rebuilds
  late final List<Widget> _pages;

  static const List<NavItemData> _navItems = [
    NavItemData(
      icon: Icons.grid_view_rounded,
      label: 'Beranda',
      accent1: AppColors.blueBook,
      accent2: AppColors.greenArrow,
    ),
    NavItemData(
      icon: Icons.menu_book_rounded,
      label: 'Validasi',
      accent1: AppColors.navy,
      accent2: AppColors.blueBook,
    ),
    NavItemData(
      icon: Icons.person_rounded,
      label: 'Profil',
      accent1: AppColors.blueGrey,
      accent2: AppColors.blueBook,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.value = 1.0; // Start fully visible

    _pages = [
      DosenMainScreen(onProfileTap: () => _onNavChanged(2)),
      const DosenHistoryScreen(),
      const DosenProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onNavChanged(int index) {
    if (index == _currentIndex) return;

    // Quick fade out then switch
    _animController.reverse().then((_) {
      setState(() {
        _currentIndex = index;
      });
      _animController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: SharedFloatingNavbar(
            items: _navItems,
            currentIndex: _currentIndex,
            onChanged: _onNavChanged,
          ),
        ),
      ),
    );
  }
}
