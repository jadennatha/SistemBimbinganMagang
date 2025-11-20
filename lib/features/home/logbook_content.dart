import 'package:flutter/material.dart';

import '../../app/app_colors.dart';

class LogbookContent extends StatelessWidget {
  const LogbookContent({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logbook',
          style: t.titleLarge?.copyWith(
            fontFamily: 'StackSansHeadline',
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Di sini nanti Kamu bisa melihat daftar logbook dan menambah entri baru.',
          style: t.bodyMedium?.copyWith(
            color: AppColors.navy.withOpacity(0.75),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: ke halaman tambah logbook
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueBook,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Tambah logbook'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 46,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: ke daftar logbook
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.navy,
              side: BorderSide(color: AppColors.navy.withOpacity(0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.list_alt),
            label: const Text('Lihat semua logbook'),
          ),
        ),
      ],
    );
  }
}
