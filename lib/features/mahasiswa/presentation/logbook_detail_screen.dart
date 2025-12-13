import 'package:flutter/material.dart';
import '../../../../app/app_colors.dart';
import '../../logbook/data/logbook_model.dart';

class LogbookDetailScreen extends StatelessWidget {
  final LogbookModel logbook;

  const LogbookDetailScreen({super.key, required this.logbook});

  Color _getStatusColor(String status) {
    if (status == 'approved') return AppColors.greenArrow;
    if (status == 'rejected') return Colors.red;
    return AppColors.blueGrey;
  }

  String _getStatusText(String status) {
    if (status == 'approved') return 'Disetujui';
    if (status == 'rejected') return 'Ditolak';
    return 'Pending';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background, // Dark Navy Background
      appBar: AppBar(
        title: Text(
          'Detail Logbook',
          style: t.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailItem(label: 'Judul Kegiatan', value: logbook.judulKegiatan),
            const SizedBox(height: 24),
            _DetailItem(label: 'Tanggal', value: _formatDate(logbook.date)),
            const SizedBox(height: 24),
            _DetailItem(
              label: 'Aktivitas',
              value: logbook.activity,
              isMultiline: true,
            ),
            if (logbook.komentar.isNotEmpty) ...[
              const SizedBox(height: 24),
              _DetailItem(
                label: 'Komentar',
                value: logbook.komentar,
                isMultiline: true,
              ),
            ],
            const SizedBox(height: 32),
            Text(
              'Status Persetujuan',
              style: t.bodySmall?.copyWith(
                color: Colors.white, // Light label
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor(logbook.statusDosen),
                    _getStatusColor(logbook.statusDosen).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor(
                      logbook.statusDosen,
                    ).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                _getStatusText(logbook.statusDosen),
                style: t.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.normal, // Biasa saja (tidak bold)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isMultiline;

  const _DetailItem({
    required this.label,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: t.bodySmall?.copyWith(
            color: Colors.white, // Light text for dark background
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight, // Keep light container (white)
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            value,
            style: t.bodyMedium?.copyWith(
              height: 1.5,
              color: AppColors.navy,
            ), // Dark text
          ),
        ),
      ],
    );
  }
}
