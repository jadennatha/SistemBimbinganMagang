import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/services/local_notification_service.dart';
import '../../../core/widgets/shared_floating_navbar.dart';

import 'dashboard_content.dart';
import 'logbook_content.dart';
import 'profile_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _previousIndex = 0;

  static const List<NavItemData> _navItems = [
    NavItemData(
      icon: Icons.grid_view_rounded,
      label: 'Beranda',
      accent1: AppColors.blueBook,
      accent2: AppColors.greenArrow,
    ),
    NavItemData(
      icon: Icons.menu_book_rounded,
      label: 'Logbook',
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
    LocalNotificationService().startListening();
  }

  void _onTabChanged(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  Widget _buildTabContent() {
    switch (_currentIndex) {
      case 0:
        return DashboardContent(onProfileTap: () => _onTabChanged(2));
      case 1:
        return const LogbookContent();
      case 2:
      default:
        return const ProfileContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool slideFromRight = _currentIndex > _previousIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _buildTabContent(),
        ),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final isEntering = child.key == ValueKey<int>(_currentIndex);
          final slideOffset = isEntering
              ? (slideFromRight ? 0.05 : -0.05)
              : (slideFromRight ? -0.05 : 0.05);

          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: Offset(slideOffset, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: SharedFloatingNavbar(
            items: _navItems,
            currentIndex: _currentIndex,
            onChanged: _onTabChanged,
          ),
        ),
      ),
    );
  }
}
