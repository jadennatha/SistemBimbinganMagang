import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // urutan halaman untuk tiap tab
    _pages = const [
      DosenMainScreen(), // dashboard dosen
      DosenHistoryScreen(), // riwayat / validasi logbook
      DosenProfileScreen(), // profil dosen
    ];
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
