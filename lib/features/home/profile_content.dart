import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  Widget _buildDataRow({
    required String label,
    required String value,
    required IconData icon,
    required TextTheme t,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.blueBook, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: t.bodySmall?.copyWith(
                  color: AppColors.navy.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: t.bodyMedium?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Belum login'));
    }

    return StreamBuilder<DocumentSnapshot>(
      // gunakan nama koleksi dan uid user
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text('Data pengguna tidak ditemukan'));
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>;
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
                        userData['email'] ?? 'Pengguna',
                        style: t.titleMedium?.copyWith(
                          fontFamily: 'StackSansHeadline',
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userData['role'] ?? 'Tidak diketahui',
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
              'Informasi Pengguna',
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 12),
            _buildDataRow(
              label: 'Nama Lengkap',
              value: userData['nama'] ?? 'Belum diisi',
              icon: Icons.person_outline,
              t: t,
            ),
            const SizedBox(height: 12),
            _buildDataRow(
              label: 'NIM',
              value: userData['nim'] ?? 'Belum diisi',
              icon: Icons.badge_outlined,
              t: t,
            ),
            const SizedBox(height: 12),
            _buildDataRow(
              label: 'Program Studi',
              value: userData['prodi'] ?? 'Belum diisi',
              icon: Icons.school_outlined,
              t: t,
            ),
            const SizedBox(height: 12),
            _buildDataRow(
              label: 'Perusahaan Magang',
              value: userData['perusahaan'] ?? 'Belum diisi',
              icon: Icons.business_center_outlined,
              t: t,
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
      },
    );
  }
}
