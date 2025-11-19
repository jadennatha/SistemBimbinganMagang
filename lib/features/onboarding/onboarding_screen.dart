import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  static const List<_PageData> _pages = [
    _PageData(
      title: 'Pantau Magang',
      subtitle: 'Catat progres dan bimbingan dalam satu aplikasi.',
      icon: Icons.timeline,
    ),
    _PageData(
      title: 'Koordinasi Mudah',
      subtitle: 'Mahasiswa, dosen, dan mentor terhubung rapi.',
      icon: Icons.group_work_outlined,
    ),
    _PageData(
      title: 'Dokumen Aman',
      subtitle: 'Upload berkas, nilai, dan logbook dengan aman.',
      icon: Icons.folder_special_outlined,
    ),
  ];

  void _next() {
    if (_index < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  void _back() {
    if (_index > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Konten halaman
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) => _OnboardPage(data: _pages[i]),
                  ),
                ),

                const SizedBox(height: 12),

                // Indikator halaman
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    final active = i == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: active ? 18 : 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(active ? 0.9 : 0.5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // Tombol navigasi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_index > 0)
                      OutlinedButton(
                        onPressed: _back,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Kembali'),
                      ),
                    if (_index > 0) const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueBook,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _index == _pages.length - 1 ? 'Mulai' : 'Selanjutnya',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageData {
  const _PageData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({required this.data});

  final _PageData data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(data.icon, size: 64, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: t.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.subtitle,
          textAlign: TextAlign.center,
          style: t.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.9),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
