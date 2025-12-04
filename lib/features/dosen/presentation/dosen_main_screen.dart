import 'package:flutter/material.dart';

import 'dosen_dashboard_content.dart';

/// Dashboard utama untuk dosen.
/// Menampilkan statistik dan aktivitas terbaru.
class DosenMainScreen extends StatelessWidget {
  const DosenMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DosenDashboardContent();
  }
}
