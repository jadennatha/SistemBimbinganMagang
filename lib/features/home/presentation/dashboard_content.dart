import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../app/app_colors.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  String _namaDariEmail(String? email) {
    if (email == null || email.isEmpty) return 'Mahasiswa';
    final depan = email.split('@').first;
    if (depan.isEmpty) return 'Mahasiswa';
    return depan[0].toUpperCase() + depan.substring(1);
  }

  String _sapaan() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi';
    if (hour < 17) return 'Selamat siang';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final namaLengkap =
        (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!
        : _namaDariEmail(user?.email);

    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: true,
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 32), // konten agak turun
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header sapaan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _sapaan(),
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      namaLengkap,
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 8,
                          color: AppColors.greenArrow,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Magang aktif',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.greenArrow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _UserBubble(name: namaLengkap),
              ],
            ),

            const SizedBox(height: 28),

            // Kartu progres
            const _ProgressCard(),

            const SizedBox(height: 24),

            // CARD RINGKASAN (PUTIH)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
                children: [
                  Text(
                    'Ringkasan minggu ini',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.navyDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _SummaryRow(
                    icon: Icons.edit_note,
                    title: 'Logbook tersimpan',
                    value: '3 entri',
                  ),
                  const SizedBox(height: 10),
                  const _SummaryRow(
                    icon: Icons.event_available,
                    title: 'Pertemuan bimbingan',
                    value: '1 jadwal',
                  ),
                  const SizedBox(height: 10),
                  const _SummaryRow(
                    icon: Icons.assignment_turned_in_outlined,
                    title: 'Progress laporan',
                    value: '40%',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CARD AKTIVITAS TERBARU (PUTIH)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
                children: [
                  Text(
                    'Aktivitas terbaru',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.navyDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _ActivityItem(
                    icon: Icons.note_alt_outlined,
                    title: 'Logbook kemarin',
                    subtitle: 'Kamu mengisi logbook pada hari sebelumnya.',
                    timeLabel: 'Kemarin',
                  ),
                  const SizedBox(height: 12),
                  const _ActivityItem(
                    icon: Icons.forum_outlined,
                    title: 'Catatan bimbingan',
                    subtitle:
                        'Dosen menambahkan catatan pada bimbingan terakhir.',
                    timeLabel: '2 hari lalu',
                  ),
                  const SizedBox(height: 12),
                  const _ActivityItem(
                    icon: Icons.upload_file_outlined,
                    title: 'Upload berkas',
                    subtitle: 'Proposal magang tersimpan di sistem.',
                    timeLabel: 'Minggu lalu',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.blueBook, AppColors.greenArrow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.background,
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatefulWidget {
  const _ProgressCard();

  @override
  State<_ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<_ProgressCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  static const double _progressValue = 0.4;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulse = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.navyDark, AppColors.blueBook],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progres magang',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.blueGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '40%',
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _progressValue),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        color: AppColors.greenArrow,
                        backgroundColor: Colors.white.withOpacity(0.25),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Lengkapi logbook dan laporan kamu secara bertahap.',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ScaleTransition(
            scale: _pulse,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.16),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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
          child: Text(
            title,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.navyDark),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.navyDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.blueBook.withOpacity(0.06),
          ),
          child: Icon(icon, size: 18, color: AppColors.blueBook),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.navy.withOpacity(0.65),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            timeLabel,
            style: textTheme.labelSmall?.copyWith(color: AppColors.blueGrey),
          ),
        ),
      ],
    );
  }
}
