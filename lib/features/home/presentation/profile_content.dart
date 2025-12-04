import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../app/app_colors.dart';
import '../../../app/routes.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  String _namaDariEmail(String? email) {
    if (email == null || email.isEmpty) return 'Mahasiswa';
    final depan = email.split('@').first;
    if (depan.isEmpty) return 'Mahasiswa';
    return depan[0].toUpperCase() + depan.substring(1);
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      // simpan navigator dulu supaya tidak pakai context setelah await
      final navigator = Navigator.of(context);

      await FirebaseAuth.instance.signOut();

      navigator.pushNamedAndRemoveUntil(Routes.login, (route) => false);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'nama@kampus.ac.id';
    final nama = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!
        : _namaDariEmail(email);

    final initial = nama.isNotEmpty ? nama[0].toUpperCase() : 'M';

    return SafeArea(
      top: true,
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header profil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [AppColors.blueBook, AppColors.navyDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.26),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.18),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: AppColors.navyDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greenArrow.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 8,
                                color: AppColors.greenArrow,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Akun aktif',
                                style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.greenArrow,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // data akun
            Text(
              'Data akun',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _SectionCard(
              children: [
                _ProfileRow(
                  icon: Icons.badge_rounded,
                  title: 'Nama lengkap',
                  value: nama,
                ),
                const SizedBox(height: 12),
                _ProfileRow(
                  icon: Icons.email_rounded,
                  title: 'Email',
                  value: email,
                ),
                const SizedBox(height: 12),
                const _ProfileRow(
                  icon: Icons.verified_user_rounded,
                  title: 'Peran di sistem',
                  value: 'Mahasiswa magang',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // informasi magang
            Text(
              'Informasi magang',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const _SectionCard(
              children: [
                _ProfileRow(
                  icon: Icons.school_rounded,
                  title: 'Program studi',
                  value: 'Informatika',
                ),
                SizedBox(height: 10),
                _ProfileRow(
                  icon: Icons.person_outline_rounded,
                  title: 'Dosen pembimbing',
                  value: 'Belum diatur',
                ),
                SizedBox(height: 10),
                _ProfileRow(
                  icon: Icons.work_outline_rounded,
                  title: 'Tempat magang',
                  value: 'Belum diatur',
                ),
              ],
            ),

            const SizedBox(height: 28),

            // tombol keluar
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => _signOut(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar dari akun'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.blueBook.withOpacity(0.07),
          ),
          child: Icon(icon, size: 18, color: AppColors.blueBook),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodySmall?.copyWith(color: AppColors.blueGrey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
