import 'package:flutter/material.dart';

import 'dosen_dashboard_content.dart';

/// Dashboard utama untuk dosen.
/// Menampilkan statistik dan aktivitas terbaru.
class DosenMainScreen extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const DosenMainScreen({super.key, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return DosenDashboardContent(onProfileTap: onProfileTap);
  }
}
