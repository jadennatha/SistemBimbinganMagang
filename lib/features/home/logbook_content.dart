import 'package:flutter/material.dart';
import '../../app/app_colors.dart';

class LogbookContent extends StatelessWidget {
  const LogbookContent({super.key});

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
              'Logbook magang',
              style: t.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Catat aktivitas harian dan pantau progres logbook kamu.',
              style: t.bodyMedium?.copyWith(
                color: AppColors.blueGrey,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            // Kartu ringkasan + CTA utama
            const _LogbookOverviewCard(),

            const SizedBox(height: 20),

            // Filter chip sederhana
            Text(
              'Filter entri',
              style: t.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const _FilterChipsRow(),

            const SizedBox(height: 20),

            // Riwayat logbook (card putih)
            const _LogbookHistoryCard(),
          ],
        ),
      ),
    );
  }
}

class _LogbookOverviewCard extends StatelessWidget {
  const _LogbookOverviewCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    const double progressValue = 3 / 7; // contoh: 3 dari 7 hari sudah terisi

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.blueBook, AppColors.greenArrow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan logbook',
            style: t.labelLarge?.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 8),
          Text(
            '5 entri minggu ini',
            style: t.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '3 dari 7 hari sudah terisi.',
            style: t.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progressValue),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  color: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.25),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Catat logbook hari ini supaya progres tetap rapi.',
                  style: t.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.95),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: arahkan ke halaman tambah logbook
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.navyDark,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Catat hari ini'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget chip(String label, {bool selected = false}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: t.bodySmall?.copyWith(
            color: selected ? AppColors.navyDark : Colors.white,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('Minggu ini', selected: true),
          chip('Bulan ini'),
          chip('Semua entri'),
        ],
      ),
    );
  }
}

class _LogbookHistoryCard extends StatelessWidget {
  const _LogbookHistoryCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
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
            'Riwayat logbook',
            style: t.titleMedium?.copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Beberapa entri terakhir yang sudah kamu simpan.',
            style: t.bodySmall?.copyWith(
              color: AppColors.navy.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 14),

          // Hari ini
          const _LogbookGroupHeader(label: 'Hari ini'),
          const SizedBox(height: 8),
          const _LogbookItem(
            title: 'Review tugas dari dosen',
            subtitle: 'Membaca dan memperbaiki laporan sesuai masukan.',
            timeLabel: '09.30',
          ),
          const SizedBox(height: 12),

          // Kemarin
          const _LogbookGroupHeader(label: 'Kemarin'),
          const SizedBox(height: 8),
          const _LogbookItem(
            title: 'Observasi proses kerja',
            subtitle: 'Mencatat alur kerja divisi tempat magang.',
            timeLabel: '14.10',
          ),
          const SizedBox(height: 12),

          // 2 hari lalu
          const _LogbookGroupHeader(label: '2 hari lalu'),
          const SizedBox(height: 8),
          const _LogbookItem(
            title: 'Rapat dengan pembimbing',
            subtitle: 'Mendiskusikan progres dan rencana minggu depan.',
            timeLabel: '10.00',
          ),

          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: ke daftar logbook lengkap
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navyDark,
                side: BorderSide(color: AppColors.navy.withOpacity(0.35)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.list_alt),
              label: const Text('Lihat semua logbook'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogbookGroupHeader extends StatelessWidget {
  const _LogbookGroupHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Text(
      label,
      style: t.labelLarge?.copyWith(
        color: AppColors.blueGrey,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _LogbookItem extends StatelessWidget {
  const _LogbookItem({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
  });

  final String title;
  final String subtitle;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.blueBook.withOpacity(0.06),
          ),
          child: const Icon(
            Icons.description_rounded,
            size: 18,
            color: AppColors.blueBook,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: t.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: t.bodySmall?.copyWith(
                  color: AppColors.navy.withOpacity(0.65),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          timeLabel,
          style: t.labelSmall?.copyWith(color: AppColors.blueGrey),
        ),
      ],
    );
  }
}
