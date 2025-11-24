import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';

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
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login,
        (route) => false,
      );
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

    return SafeArea(
      top: true,
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header profil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [AppColors.blueBook, AppColors.navyDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 18,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.background,
                      child: Text(
                        nama.isNotEmpty ? nama[0].toUpperCase() : 'M',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.greenArrow.withOpacity(0.14),
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

            const SizedBox(height: 20),

            // pengaturan aplikasi
            Text(
              'Pengaturan aplikasi',
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const _SectionCard(
              children: [
                _SettingTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifikasi bimbingan',
                  subtitle: 'Ingatkan sebelum jadwal dimulai.',
                ),
                SizedBox(height: 8),
                _SettingTile(
                  icon: Icons.palette_outlined,
                  title: 'Tampilan aplikasi',
                  subtitle: 'Mengikuti tema biru E-Bimbingan.',
                ),
                SizedBox(height: 8),
                _SettingTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang aplikasi',
                  subtitle: 'Versi 1.0.0 • E-Bimbingan Magang.',
                ),
              ],
            ),

            const SizedBox(height: 24),

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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.blueBook.withOpacity(0.06),
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

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blueBook.withOpacity(0.06),
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
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.navyDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.navy.withOpacity(0.65),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.blueGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
