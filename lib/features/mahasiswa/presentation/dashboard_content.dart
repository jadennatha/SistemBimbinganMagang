import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../app/app_colors.dart';
import '../../../core/services/firestore_service.dart';
import '../../logbook/data/logbook_model.dart';
import '../../logbook/data/logbook_service.dart';
import 'logbook_detail_screen.dart';
import '../../notification/presentation/notification_screen.dart';
import '../../../core/services/notification_service.dart';

class DashboardContent extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const DashboardContent({super.key, this.onProfileTap});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late final LogbookService _logbookService;
  late String _studentId;
  bool _isUserInitialized = false;

  @override
  void initState() {
    super.initState();
    _logbookService = LogbookService();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    try {
      final currentUserId = _logbookService.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User tidak login');
      }
      setState(() {
        _studentId = currentUserId;
        _isUserInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

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

  void _showLogbookDetail(LogbookModel logbook) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LogbookDetailScreen(logbook: logbook)),
    );
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
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header sapaan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center, // Align Center
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
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            namaLengkap,
                            style: textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // "Magang aktif" moved here
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.greenArrow.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: AppColors.greenArrow,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Magang aktif',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: AppColors.greenArrow,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Notification Bell
                StreamBuilder<int>(
                  stream: NotificationService().getUnreadCountStream(
                    _studentId,
                  ),
                  builder: (context, snapshot) {
                    final unreadCount = snapshot.data ?? 0;
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: const SizedBox(
                                height: 500,
                                child: NotificationScreen(),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 10,
                                  minHeight: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: widget.onProfileTap, // Use callback
                  child: _UserBubble(name: namaLengkap),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Kartu progres
            _ProgressCard(studentId: _studentId),

            const SizedBox(height: 24),

            // CARD RINGKASAN (PUTIH)
            if (_isUserInitialized)
              _SummaryCard(
                logbookService: _logbookService,
                studentId: _studentId,
              )
            else
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
                child: const Center(child: CircularProgressIndicator()),
              ),

            const SizedBox(height: 20),

            // CARD AKTIVITAS TERBARU (PUTIH)
            if (_isUserInitialized)
              _ActivityCard(
                logbookService: _logbookService,
                studentId: _studentId,
                onLogbookTap: _showLogbookDetail,
              )
            else
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
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

// ============ SUMMARY CARD ============
class _SummaryCard extends StatelessWidget {
  final LogbookService logbookService;
  final String studentId;

  const _SummaryCard({required this.logbookService, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final logbookService = LogbookService();
    final firestoreService = FirestoreService();

    return StreamBuilder<List<LogbookModel>>(
      stream: logbookService.getStudentLogbooksVerified(studentId),
      builder: (context, snapshot) {
        final allLogbooks = snapshot.data ?? [];
        final logbookCount = allLogbooks.length;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
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
                'Ringkasan Dashboard',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _SummaryRow(
                icon: Icons.edit_note,
                title: 'Logbook Terverifikasi',
                value: '$logbookCount Entri',
              ),
              const SizedBox(height: 10),
              StreamBuilder<String>(
                stream: firestoreService.getUserTotalInternday(studentId),
                builder: (context, snapshot) {
                  final totalHari = snapshot.data ?? '0';
                  return _SummaryRow(
                    icon: Icons.assignment_add,
                    title: 'Logbook Yang Harus Dibuat',
                    value: '$totalHari Logbook',
                  );
                },
              ),
              const SizedBox(height: 10),
              StreamBuilder<double>(
                stream: firestoreService.getInternshipProgressStream(
                  studentId,
                  'logbooks',
                ),
                builder: (context, progressSnapshot) {
                  final progressValue = progressSnapshot.data ?? 0.0;
                  final progressPercent = (progressValue * 100).toStringAsFixed(
                    1,
                  );
                  return _SummaryRow(
                    icon: Icons.assignment_turned_in_outlined,
                    title: 'Progress laporan',
                    value: '$progressPercent%',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============ ACTIVITY CARD ============
class _ActivityCard extends StatelessWidget {
  final LogbookService logbookService;
  final String studentId;
  final Function(LogbookModel) onLogbookTap;

  const _ActivityCard({
    required this.logbookService,
    required this.studentId,
    required this.onLogbookTap,
  });

  String _capitalizeWords(String input) {
    if (input.isEmpty) return input;
    return input
        .split(' ')
        .map((str) {
          if (str.isEmpty) return str;
          return str[0].toUpperCase() + str.substring(1);
        })
        .join(' ');
  }

  String _getTimeLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final logDate = DateTime(date.year, date.month, date.day);

    String label;
    if (logDate.isAtSameMomentAs(today)) {
      label = 'hari ini';
    } else if (logDate.isAtSameMomentAs(yesterday)) {
      label = 'kemarin';
    } else {
      final diff = today.difference(logDate).inDays;
      if (diff < 7) {
        label = '$diff hari lalu';
      } else if (diff < 30) {
        final weeks = diff ~/ 7;
        label = '$weeks minggu lalu';
      } else {
        final months = diff ~/ 30;
        label = '$months bulan lalu';
      }
    }
    return _capitalizeWords(label);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<List<LogbookModel>>(
      stream: logbookService.getStudentLogbooks(studentId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final allLogbooks = snapshot.data ?? [];
        final sortedLogbooks = allLogbooks.toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        final recentLogbooks = sortedLogbooks.take(5).toList();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
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
                'Aktivitas Terbaru', // Capitalized
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (recentLogbooks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'Belum ada logbook',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.navy.withOpacity(0.65),
                      ),
                    ),
                  ),
                )
              else
                ...List.generate(recentLogbooks.length, (index) {
                  final logbook = recentLogbooks[index];
                  return GestureDetector(
                    onTap: () => onLogbookTap(logbook),
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: index < recentLogbooks.length - 1 ? 12 : 0,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.navy.withOpacity(0.1),
                          ),
                        ),
                        child: _ActivityItemFromLogbook(
                          logbook: logbook,
                          timeLabel: _getTimeLabel(logbook.createdAt),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

// ============ ACTIVITY ITEM FROM LOGBOOK ============
class _ActivityItemFromLogbook extends StatelessWidget {
  final LogbookModel logbook;
  final String timeLabel;

  const _ActivityItemFromLogbook({
    required this.logbook,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Center Vertically
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.blueBook.withOpacity(0.06),
          ),
          child: const Icon(
            Icons.note_alt_outlined,
            size: 18,
            color: AppColors.blueBook,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                logbook.judulKegiatan,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                logbook.activity,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.navy.withOpacity(0.65),
                  height: 1.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
  final String studentId;
  const _ProgressCard({required this.studentId});

  @override
  State<_ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<_ProgressCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;
  final _firestoreService = FirestoreService();

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

    return StreamBuilder<double>(
      stream: _firestoreService.getInternshipProgressStream(
        widget.studentId,
        'logbooks',
      ),
      builder: (context, snapshot) {
        double progressValue = snapshot.data ?? 0.0;

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
                      'Progres Magang', // Capitalized
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(progressValue * 100).toStringAsFixed(1)}%',
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
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
                            color: AppColors.greenArrow,
                            backgroundColor: Colors.white.withOpacity(0.25),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Lengkapi Logbook dan Laporan kamu secara bertahap.', // Capitalized
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
      },
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
