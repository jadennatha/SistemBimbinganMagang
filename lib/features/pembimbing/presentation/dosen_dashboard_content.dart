import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';
import '../../auth/data/auth_provider.dart';
import '../data/logbook_validation_service.dart';
import '../data/dashboard_stats.dart';
import '../data/logbook_validation_models.dart';

import '../../../app/app_colors.dart';

class DosenDashboardContent extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const DosenDashboardContent({super.key, this.onProfileTap});

  @override
  State<DosenDashboardContent> createState() => _DosenDashboardContentState();
}

class _DosenDashboardContentState extends State<DosenDashboardContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  String _nama = 'User';
  final LogbookValidationService _validationService =
      LogbookValidationService();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _loadUserData();
    _fadeController.forward();
  }

  Future<void> _loadUserData() async {
    // Fetch role terlebih dahulu
    final authProvider = context.read<AuthProvider>();
    await authProvider.fetchUserRole();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && mounted) {
          final data = doc.data();
          setState(() {
            _nama = data?['nama'] ?? 'User';
          });
        }
      } catch (e) {
        // Error handling
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _sapaan() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi';
    if (hour < 17) return 'Selamat siang';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authProvider = context.watch<AuthProvider>();
    final isMentor = authProvider.isMentor;
    final roleLabel = isMentor ? 'Mentor' : 'Dosen Pembimbing';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Centered layout like mahasiswa
              Row(
                children: [
                  // Profile bubble (tappable to go to profile)
                  GestureDetector(
                    onTap: widget.onProfileTap,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF2FB1E3), Color(0xFF2454B5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.background,
                        child: Text(
                          _nama.isNotEmpty ? _nama[0].toUpperCase() : 'D',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Name and role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _sapaan(),
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _nama,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.greenArrow.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                roleLabel,
                                style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.greenArrow,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Stats Card
              _buildStatsCard(textTheme),

              const SizedBox(height: 20),
              // Recent Activity
              _buildRecentActivity(textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(TextTheme textTheme) {
    final user = FirebaseAuth.instance.currentUser;
    final authProvider = context.watch<AuthProvider>();
    final isMentor = authProvider.isMentor;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DashboardStats>(
      stream: _validationService.getDashboardStats(user.uid, isMentor),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF2FB1E3), Color(0xFF2454B5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final stats = snapshot.data ?? DashboardStats.empty();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with animated icon and title
              Row(
                children: [
                  // Static icon (removed animation for performance)
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Logbook',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Animated counter with bounce effect
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: stats.totalLogbooks),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$value',
                                  style: textTheme.displaySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    'Entri',
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: Colors.white.withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Mini stat cards with staggered animation
              Row(
                children: [
                  _buildAnimatedMiniStat(
                    'Disetujui',
                    stats.approvedCount,
                    Icons.check_circle_rounded,
                    const Color(0xFF10B981),
                    0,
                  ),
                  const SizedBox(width: 10),
                  _buildAnimatedMiniStat(
                    'Ditolak',
                    stats.revisionCount,
                    Icons.cancel_rounded,
                    Colors.red,
                    1,
                  ),
                  const SizedBox(width: 10),
                  _buildAnimatedMiniStat(
                    'Mahasiswa',
                    stats.studentCount,
                    Icons.people_rounded,
                    Colors.white,
                    2,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedMiniStat(
    String label,
    int value,
    IconData icon,
    Color color,
    int index,
  ) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 600 + (index * 150)),
        curve: Curves.easeOutBack,
        builder: (context, anim, child) {
          return Transform.scale(
            scale: anim,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: value),
                    duration: Duration(milliseconds: 800 + (index * 100)),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, _) {
                      return Text(
                        '$val',
                        style: TextStyle(
                          color: color,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(TextTheme textTheme) {
    final user = FirebaseAuth.instance.currentUser;
    final authProvider = context.watch<AuthProvider>();
    final isMentor = authProvider.isMentor;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<LogbookValidationItem>>(
      stream: _validationService.getRecentActivities(
        user.uid,
        isMentor,
        limit: 5,
      ),
      builder: (context, snapshot) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4F7),
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
                'Aktivitas Terbaru',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SizedBox.shrink()
              else if (snapshot.hasError)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Gagal memuat aktivitas',
                      style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ),
                )
              else if (!snapshot.hasData || snapshot.data!.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Belum ada aktivitas',
                      style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...snapshot.data!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == snapshot.data!.length - 1;
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDFEFD),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: _buildActivityItemFromLogbook(item),
                      ),
                      if (!isLast) const SizedBox(height: 10),
                    ],
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityItemFromLogbook(LogbookValidationItem item) {
    IconData icon;
    String title;
    Color color;

    if (item.isApproved) {
      icon = Icons.check_circle_outline;
      title = 'Logbook Disetujui';
      color = AppColors.greenArrow;
    } else if (item.isRevision) {
      icon = Icons.cancel_rounded;
      title = 'Ditolak';
      color = Colors.red;
    } else {
      icon = Icons.edit_note_rounded;
      title = 'Logbook baru';
      color = AppColors.blueBook;
    }

    return _buildActivityItem(
      icon: icon,
      title: title,
      subtitle: '${item.studentName} - ${item.title}',
      time: item.dateLabel,
      color: color,
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Centered icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
          child: Center(child: Icon(icon, color: color, size: 20)),
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.navy.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Date - centered with icon
        Text(
          time,
          style: TextStyle(
            color: AppColors.blueGrey.withOpacity(0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
