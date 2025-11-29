import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../app/app_colors.dart';
import '../../app/routes.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
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
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 18,
                        offset: Offset(0, 12),
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
                  'Data Akun',
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
                      ? 'Informasi Mahasiswa'
                      : (user.role == 'dosen'
                          ? 'Informasi Akademik'
                          : 'Informasi Perusahaan'),
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                // === ISI INFORMASI ===
                _SectionCard(
                  children: [
                    // JIKA MAHASISWA
                    if (user.role == 'mahasiswa') ...[
                      _ProfileRow(
                        icon: Icons.numbers_rounded, 
                        title: 'NIM',
                        value: user.nim ?? '-',
                      ),
                      const SizedBox(height: 10,),
                      _ProfileRow(
                        icon: Icons.school_rounded,
                        title: 'Program studi',
                        value: user.prodi ?? '-',
                      ),
                      const SizedBox(height: 10),
                      _ProfileRow(
                        icon: Icons.class_rounded,
                        title: 'Kelas',
                        value: user.kelas ?? '-',
                      ),
                      const SizedBox(height: 10),
                      _ProfileRow(
                        icon: Icons.apartment_rounded, 
                        title: 'Perusahaan Magang',
                        value: user.perusahaan ?? '-',
                      ),
                      const SizedBox(height: 10),
                      _ProfileRow(
                        icon: Icons.work_outline_rounded,
                        title: 'Posisi Magang',
                        value: user.posisi ?? '-',
                      ),
                      const SizedBox(height: 10),
                      
                      // -- Menampilkan MENTOR (Fetch dari ID) --
                      _ProfileRow(
                        icon: Icons.business_rounded,
                        title: 'Mentor Perusahaan',
                        customWidget: _UserNameFetcher(
                          userId: user.mentorId,
                          fallbackText: user.perusahaan ?? 'Belum ada',
                        ),
                      ),

                      const SizedBox(height: 10),
                      
                      // -- Menampilkan DOSEN (Fetch dari ID) --
                      _ProfileRow(
                        icon: Icons.person_rounded,
                        title: 'Dosen Pembimbing',
                        customWidget: _UserNameFetcher(
                          userId: user.dosenId,
                          fallbackText: 'Belum ditentukan',
                        ),
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

                    // JIKA MENTOR
                    if (user.role == 'mentor') ...[
                      _ProfileRow(
                        icon: Icons.apartment_rounded,
                        title: 'Perusahaan',
                        value: user.perusahaan ?? '-',
                      ),
                    ],

                    // JIKA ROLE TIDAK DIKENALI
                    if (user.role != 'mahasiswa' &&
                        user.role != 'dosen' &&
                        user.role != 'mentor')
                      Text(
                        "Role tidak dikenali: ${user.role}",
                        style: const TextStyle(color: Colors.red),
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

// =======================================================
// WIDGET HELPERS
// =======================================================

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
    // super.key,
    required this.icon,
    required this.title,
    this.value,        // Tidak required lagi
    this.customWidget, // Tambahan untuk widget loading
  });

  final IconData icon;
  final String title;
  final String? value;
  final Widget? customWidget;

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
              
              // Jika ada customWidget (misal loading nama dosen), pakai itu.
              // Jika tidak, pakai Text biasa.
              customWidget ?? 
              Text(
                value ?? '-',
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

// Widget khusus untuk mengambil Nama dari User ID (Firestore)
class _UserNameFetcher extends StatelessWidget {
  final String? userId;
  final String fallbackText;

  const _UserNameFetcher({
    // super.key,
    required this.userId,
    this.fallbackText = '-',
  });

  @override
  Widget build(BuildContext context) {
    // 1. Jika ID kosong, tampilkan fallback
    if (userId == null || userId!.isEmpty) {
      return Text(
        fallbackText,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.w600,
            ),
      );
    }

    // 2. Ambil data user dari Firestore berdasarkan ID
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("...", style: TextStyle(color: Colors.grey));
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final nama = data['nama'] ?? 'Tanpa Nama';

          return Text(
            nama,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.w600,
                ),
          );
        }

        return const Text(
          "Tidak ditemukan",
          style: TextStyle(color: Colors.red, fontSize: 12),
        );
      },
    );
  }
}