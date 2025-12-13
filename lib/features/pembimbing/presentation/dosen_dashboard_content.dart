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
  const DosenDashboardContent({super.key});

  @override
  State<DosenDashboardContent> createState() => _DosenDashboardContentState();
}

class _DosenDashboardContentState extends State<DosenDashboardContent>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  String _nama = 'User';
  String _nip = '';
  bool _isLoading = true;
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

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
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
            _nip = data?['nip'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
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

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
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
                          _nama,
                          style: textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_nip.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'NIP: $_nip',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.blueGrey,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified,
                              size: 14,
                              color: AppColors.greenArrow,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              roleLabel,
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.greenArrow,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _UserBubble(name: _nama),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF2FB1E3), Color(0xFF2454B5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
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
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: stats.totalLogbooks),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, _) {
                            return Text(
                              '$value entri',
                              style: textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildMiniStat(
                    'Disetujui',
                    '${stats.approvedCount}',
                    AppColors.greenArrow,
                  ),
                  const SizedBox(width: 12),
                  _buildMiniStat(
                    'Revisi',
                    '${stats.revisionCount}',
                    Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _buildMiniStat(
                    'Mahasiswa',
                    '${stats.studentCount}',
                    Colors.white,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
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
                'Aktivitas Terbaru',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
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
                  return Column(
                    children: [
                      if (index > 0) const SizedBox(height: 12),
                      _buildActivityItemFromLogbook(item),
                    ],
                  );
                }).toList(),
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
      title = 'Logbook disetujui';
      color = AppColors.greenArrow;
    } else if (item.isRevision) {
      icon = Icons.replay_rounded;
      title = 'Revisi diminta';
      color = Colors.orange;
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
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.06),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                style: TextStyle(
                  color: AppColors.navy.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(color: AppColors.blueGrey, fontSize: 11),
        ),
      ],
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF2FB1E3), Color(0xFF2454B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.background,
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
