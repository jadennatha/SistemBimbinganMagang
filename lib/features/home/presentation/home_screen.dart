import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [DashboardContent(), LogbookContent(), ProfileContent()];
  }

  void _onNavChanged(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavChanged,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.navyDark,
          unselectedItemColor: AppColors.blueGrey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _GradientIcon(
                icon: Icons.dashboard_rounded,
                isSelected: _currentIndex == 0,
                gradient: const LinearGradient(
                  colors: [AppColors.blueBook, AppColors.greenArrow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: _GradientIcon(
                icon: Icons.menu_book_rounded,
                isSelected: _currentIndex == 1,
                gradient: const LinearGradient(
                  colors: [AppColors.navyDark, AppColors.blueBook],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              label: 'Logbook',
            ),
            BottomNavigationBarItem(
              icon: _GradientIcon(
                icon: Icons.person_rounded,
                isSelected: _currentIndex == 2,
                gradient: const LinearGradient(
                  colors: [AppColors.navy, AppColors.greenArrow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget icon dengan gradient untuk navbar
class _GradientIcon extends StatelessWidget {
  const _GradientIcon({
    required this.icon,
    required this.isSelected,
    required this.gradient,
  });

  final IconData icon;
  final bool isSelected;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    if (!isSelected) {
      return Icon(icon, size: 24, color: AppColors.blueGrey);
    }

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return gradient.createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Icon(icon, size: 26, color: Colors.white),
    );
  }
}
