import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../app/app_colors.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

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

        Widget statArea;
        if (isWide) {
          statArea = Row(
            children: const [
              Expanded(
                child: StatCard(
                  title: 'Logbook minggu ini',
                  value: '0',
                  subtitle: 'Entri yang sudah dibuat',
                  icon: Icons.edit_note,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: StatCard(
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
              StatCard(
                title: 'Logbook minggu ini',
                value: '0',
                subtitle: 'Entri yang sudah dibuat',
                icon: Icons.edit_note,
              ),
              SizedBox(height: 12),
              StatCard(
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

class StatCard extends StatelessWidget {
  const StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    super.key,
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
