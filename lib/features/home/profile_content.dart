import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Tidak perlu jika pakai service

import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../app/app_colors.dart';
import '../../app/routes.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      // simpan navigator dulu supaya tidak pakai context setelah await
      final navigator = Navigator.of(context);

      await FirebaseAuth.instance.signOut();

      navigator.pushNamedAndRemoveUntil(Routes.login, (route) => false);
    } catch (_) {}
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final userAuth = FirebaseAuth.instance.currentUser;

    if (userAuth == null) {
      return const Center(child: Text("User tidak terdeteksi"));
    }

    return StreamBuilder<UserModel>(
      stream: FirestoreService().getUserStream(userAuth.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("Data profil belum lengkap."));
        }

        final user = snapshot.data!;

        return SafeArea(
          top: true,
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER PROFIL ===
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
                            user.nama.isNotEmpty
                                ? user.nama[0].toUpperCase()
                                : 'U',
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
                              user.nama,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.greenArrow.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Akun aktif',
                                style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.greenArrow,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // === DATA AKUN ===
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
                      value: user.nama,
                    ),
                    const SizedBox(height: 12),
                    _ProfileRow(
                      icon: Icons.email_rounded,
                      title: 'Email',
                      value: user.email,
                    ),
                    const SizedBox(height: 12),
                    _ProfileRow(
                      icon: Icons.verified_user_rounded,
                      title: 'Peran di sistem',
                      value: _capitalize(user.role),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // === LOGIKA JUDUL DINAMIS ===
                Text(
                  user.role == 'mahasiswa'
                      ? 'Informasi Magang'
                      : (user.role == 'dosen'
                            ? 'Informasi Akademik'
                            : 'Informasi Perusahaan'),
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                // === ISI INFORMASI (Cek Logic di sini) ===
                _SectionCard(
                  children: [
                    // JIKA MAHASISWA
                    if (user.role == 'mahasiswa') ...[
                      _ProfileRow(
                        icon: Icons.school_rounded,
                        title: 'Program studi',
                        value:
                            user.prodi ??
                            '-', // <-- Cek di Firestore ada field 'jurusan' ga?
                      ),
                      const SizedBox(height: 10),
                      _ProfileRow(
                        icon: Icons.class_rounded,
                        title: 'Kelas',
                        value: user.kelas ?? '-', // <-- Cek field 'kelas'
                      ),
                      const SizedBox(height: 10),
                      _ProfileRow(
                        icon: Icons.business_rounded,
                        title: 'Tempat Magang',
                        value: user.perusahaan ?? 'Belum ada',
                      ),
                      const SizedBox(height: 10),
                      _ProfileRow(
                        icon: Icons.person_rounded,
                        title: 'Dosen Pembimbing',
                        value: user.dosenID ?? '-',
                      ),
                    ],

                    // JIKA DOSEN
                    if (user.role == 'dosen') ...[
                      _ProfileRow(
                        icon: Icons.numbers_rounded,
                        title: 'NIP',
                        value: user.nip ?? '-',
                      ),
                      const SizedBox(height: 10),
                      _ProfileRow(
                        icon: Icons.business_rounded,
                        title: 'Fakultas',
                        value: user.fakultas ?? '-',
                      ),
                    ],

                    // JIKA MENTOR / LAINNYA (Fallback)
                    if (user.role == 'mentor') ...[
                      _ProfileRow(
                        icon: Icons.apartment_rounded,
                        title: 'Perusahaan',
                        value: user.perusahaan ?? '-',
                      ),
                    ],

                    // JIKA DATA KOSONG (DEBUGGING HELP)
                    // Kalau role tidak cocok sama sekali, munculkan teks ini biar tau
                    if (user.role != 'mahasiswa' &&
                        user.role != 'dosen' &&
                        user.role != 'mentor')
                      Text(
                        "Role tidak dikenali: ${user.role}",
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // === TOMBOL KELUAR ===
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
      },
    );
  }
}

// Widget Helper (_SectionCard, _ProfileRow, dll) biarkan sama seperti sebelumnya
// ...
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    // Tambahkan constraint minHeight biar kalau kosong minimal kelihatan kotak putihnya
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.isEmpty
            ? [const Text("Tidak ada informasi tambahan.")]
            : children,
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
