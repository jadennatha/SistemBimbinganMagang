import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
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
      extendBody: true,
      // IndexedStack supaya state tiap tab tetap tersimpan
      body: IndexedStack(index: _currentIndex, children: _pages),
      // navbar melayang di bawah
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: DosenFloatingNavbar(
            currentIndex: _currentIndex,
            onChanged: _onNavChanged,
          ),
        ),
      ),
    );
  }
}
