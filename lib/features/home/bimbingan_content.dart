import 'package:flutter/material.dart';
import '../../app/app_colors.dart';

class BimbinganContent extends StatelessWidget {
  const BimbinganContent({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return SafeArea(
      top: true,
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Bimbingan',
              style: t.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pantau jadwal, status, dan catatan setiap sesi bimbingan.',
              style: t.bodyMedium?.copyWith(
                color: AppColors.blueGrey,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            // Baris statistik singkat
            Row(
              children: const [
                Expanded(
                  child: _StatCard(
                    icon: Icons.event_available_rounded,
                    label: 'Terjadwal',
                    value: '2',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Selesai',
                    value: '5',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.note_alt_outlined,
                    label: 'Catatan',
                    value: '3',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Jadwal terdekat
            Text(
              'Jadwal terdekat',
              style: t.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const _NextSessionCard(),

            const SizedBox(height: 24),

            // Timeline riwayat bimbingan
            Text(
              'Riwayat bimbingan',
              style: t.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Urutan bimbingan terbaru, lengkap dengan status dan ringkasan.',
              style: t.bodySmall?.copyWith(color: AppColors.blueGrey),
            ),
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
              child: const Column(
                children: [
                  _TimelineSessionItem(
                    title: 'Revisi bab metode',
                    subtitle: 'Membahas perbaikan rumusan metode penelitian.',
                    dateLabel: '3 hari lalu',
                    status: 'Selesai',
                    statusColor: AppColors.greenArrow,
                    isFirst: true,
                  ),
                  _TimelineSessionItem(
                    title: 'Cek progres logbook',
                    subtitle: 'Dosen mengecek kelengkapan entri logbook.',
                    dateLabel: 'Minggu lalu',
                    status: 'Selesai',
                    statusColor: AppColors.blueBook,
                  ),
                  _TimelineSessionItem(
                    title: 'Rencana presentasi akhir',
                    subtitle: 'Menentukan struktur slide dan pembagian materi.',
                    dateLabel: '2 minggu lalu',
                    status: 'Catatan',
                    statusColor: AppColors.navy,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 42,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: arahkan ke daftar bimbingan lengkap
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.history_rounded),
                label: const Text('Lihat semua bimbingan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blueBook.withOpacity(0.08),
            ),
            child: Icon(icon, size: 18, color: AppColors.blueBook),
          ),
          const SizedBox(height: 2, width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: t.titleMedium?.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  style: t.bodySmall?.copyWith(
                    color: AppColors.navy.withOpacity(0.7),
                    height: 1.2,
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

class _NextSessionCard extends StatelessWidget {
  const _NextSessionCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [AppColors.blueBook, AppColors.greenArrow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.schedule_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rabu, 12 Juni 09.00',
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bimbingan laporan bab 3 dengan Dosen Pembimbing.',
                  style: t.bodySmall?.copyWith(
                    color: AppColors.navy.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greenArrow.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Terjadwal',
                  style: t.labelSmall?.copyWith(
                    color: AppColors.greenArrow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () {
                  // TODO: lihat detail jadwal
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.blueBook,
                ),
                child: const Text('Detail'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineSessionItem extends StatelessWidget {
  const _TimelineSessionItem({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.status,
    required this.statusColor,
    this.isFirst = false,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final String dateLabel;
  final String status;
  final Color statusColor;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Garis timeline
        Column(
          children: [
            Container(
              width: 16,
              alignment: Alignment.center,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withOpacity(0.18),
                  border: Border.all(color: statusColor, width: 2),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                margin: const EdgeInsets.only(top: 2),
                color: Colors.grey.withOpacity(0.25),
              )
            else
              const SizedBox(height: 46),
          ],
        ),
        const SizedBox(width: 10),
        // Konten
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: isFirst ? 0 : 4,
              bottom: isLast ? 0 : 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: t.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.navyDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateLabel,
                      style: t.labelSmall?.copyWith(color: AppColors.blueGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: t.bodySmall?.copyWith(
                    color: AppColors.navy.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status,
                    style: t.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
