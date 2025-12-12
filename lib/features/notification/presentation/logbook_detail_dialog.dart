import 'package:flutter/material.dart';
import '../../../app/app_colors.dart';
import '../../logbook/data/logbook_model.dart';

class LogbookDetailDialog extends StatelessWidget {
  final LogbookModel logbook;

  const LogbookDetailDialog({super.key, required this.logbook});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'Detail Logbook',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 24),

            // Judul Kegiatan
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Judul Kegiatan',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.navy.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                logbook.judulKegiatan,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),

            // Tanggal
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tanggal',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.navy.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatDate(logbook.date),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),

            // Aktivitas
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Aktivitas',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.navy.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                logbook.activity,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 20),

            // Status Persetujuan
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Status Persetujuan',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.navy.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _getStatusBackgroundColor(logbook.statusDosen),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Dosen',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusText(logbook.statusDosen),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getStatusTextColor(logbook.statusDosen),
                    ),
                  ),
                ],
              ),
            ),

            // Komentar (if exists)
            if (logbook.komentar.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Komentar',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[300],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  logbook.komentar,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Tutup Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueBook,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusBackgroundColor(String status) {
    if (status == 'approved') {
      return Colors.green[50]!;
    } else if (status == 'rejected') {
      return Colors.red[50]!;
    }
    return Colors.grey[200]!;
  }

  Color _getStatusTextColor(String status) {
    if (status == 'approved') {
      return Colors.green[700]!;
    } else if (status == 'rejected') {
      return Colors.red[700]!;
    }
    return Colors.grey[700]!;
  }

  String _getStatusText(String status) {
    if (status == 'approved') {
      return 'APPROVED';
    } else if (status == 'rejected') {
      return 'REJECTED';
    }
    return 'PENDING';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
