import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';

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
              child: _FloatingNavBar(
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
        return const _DashboardContent();
      case 1:
        return const _LogbookContent();
      case 2:
      default:
        return const _ProfileContent();
    }
  }
}

// ---------------- DASHBOARD CONTENT ----------------

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  String _namaDariEmail(String? email) {
    if (email == null || email.isEmpty) return 'Mahasiswa';
    final depan = email.split('@').first;
    if (depan.isEmpty) return 'Mahasiswa';
    return depan[0].toUpperCase() + depan.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final nama = _namaDariEmail(user?.email);
    final t = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 600;

        // Di HP sempit kartu ditumpuk, di layar lebar sejajar
        Widget statArea;
        if (isWide) {
          statArea = Row(
            children: const [
              Expanded(
                child: _StatCard(
                  title: 'Logbook minggu ini',
                  value: '0',
                  subtitle: 'Entri yang sudah dibuat',
                  icon: Icons.edit_note,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  title: 'Status bimbingan',
                  value: 'Belum ada',
                  subtitle: 'Menunggu entri pertama',
                  icon: Icons.verified_outlined,
                ),
              ),
            ],
          );
        } else {
          statArea = Column(
            children: const [
              _StatCard(
                title: 'Logbook minggu ini',
                value: '0',
                subtitle: 'Entri yang sudah dibuat',
                icon: Icons.edit_note,
              ),
              SizedBox(height: 12),
              _StatCard(
                title: 'Status bimbingan',
                value: 'Belum ada',
                subtitle: 'Menunggu entri pertama',
                icon: Icons.verified_outlined,
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: t.titleLarge?.copyWith(
                fontFamily: 'StackSansHeadline',
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Halo, $nama',
              style: t.headlineSmall?.copyWith(
                fontFamily: 'StackSansHeadline',
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ringkasan aktivitas magang Kamu.',
              style: t.bodyMedium?.copyWith(
                color: AppColors.navy.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            statArea,
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: arahkan ke halaman tambah logbook
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueBook,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Catat logbook hari ini'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: arahkan ke daftar logbook
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  side: BorderSide(color: AppColors.navy.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.list_alt),
                label: const Text('Lihat riwayat logbook'),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Angka di atas masih dummy. Nanti dihubungkan ke Firestore.',
              style: t.bodySmall?.copyWith(
                color: AppColors.navy.withOpacity(0.5),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.blueBook.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.blueBook, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: t.labelMedium?.copyWith(
                    color: AppColors.navy.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: t.titleLarge?.copyWith(
                    fontFamily: 'StackSansHeadline',
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: t.bodySmall?.copyWith(
                    color: AppColors.navy.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- LOGBOOK CONTENT ----------------

class _LogbookContent extends StatelessWidget {
  const _LogbookContent();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logbook',
          style: t.titleLarge?.copyWith(
            fontFamily: 'StackSansHeadline',
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Di sini nanti Kamu bisa melihat daftar logbook dan menambah entri baru.',
          style: t.bodyMedium?.copyWith(
            color: AppColors.navy.withOpacity(0.75),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: ke halaman tambah logbook
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueBook,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Tambah logbook'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 46,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: ke daftar logbook
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.navy,
              side: BorderSide(color: AppColors.navy.withOpacity(0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.list_alt),
            label: const Text('Lihat semua logbook'),
          ),
        ),
      ],
    );
  }
}

// ---------------- PROFILE CONTENT ----------------

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profil',
          style: t.titleLarge?.copyWith(
            fontFamily: 'StackSansHeadline',
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.blueBook.withOpacity(0.15),
              child: const Icon(
                Icons.person,
                color: AppColors.blueBook,
                size: 32,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.email ?? 'Pengguna',
                    style: t.titleMedium?.copyWith(
                      fontFamily: 'StackSansHeadline',
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Role: Mahasiswa (sementara)',
                    style: t.bodySmall?.copyWith(
                      color: AppColors.navy.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Pengaturan akun',
          style: t.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.lock_outline, color: AppColors.navy),
          title: const Text('Ubah password'),
          subtitle: Text(
            'Belum diimplementasikan',
            style: t.bodySmall?.copyWith(
              color: AppColors.navy.withOpacity(0.6),
            ),
          ),
          onTap: () {
            // TODO: ubah password
          },
        ),
        const Divider(height: 28),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, Routes.login);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              side: BorderSide(color: Colors.red.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Keluar'),
          ),
        ),
      ],
    );
  }
}

// ---------------- FLOATING NAVBAR ----------------

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({required this.currentIndex, required this.onChanged});

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12), // shadow lebih kecil
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _NavItem(
              index: 0,
              currentIndex: currentIndex,
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              onTap: onChanged,
            ),
            _NavItem(
              index: 1,
              currentIndex: currentIndex,
              icon: Icons.edit_note_outlined,
              label: 'Logbook',
              onTap: onChanged,
            ),
            _NavItem(
              index: 2,
              currentIndex: currentIndex,
              icon: Icons.person_outline,
              label: 'Profil',
              onTap: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bool selected = index == currentIndex;
    final Color activeColor = AppColors.blueBook;
    final Color inactiveColor = AppColors.navy.withOpacity(0.6);
    final Color iconColor = selected ? activeColor : inactiveColor;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            color: selected
                ? activeColor.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: iconColor,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
