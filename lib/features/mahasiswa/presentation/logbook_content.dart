import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../app/app_colors.dart';
import '../../logbook/data/logbook_model.dart';
import '../../logbook/data/logbook_service.dart';
import 'create_logbook_screen.dart';
import 'logbook_detail_screen.dart';

class LogbookContent extends StatefulWidget {
  const LogbookContent({super.key});

  @override
  State<LogbookContent> createState() => _LogbookContentState();
}

class _LogbookContentState extends State<LogbookContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _btnController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;
  final LogbookService _logbookService = LogbookService();
  late String _studentId;
  late String _dosenId;
  late String _mentorId;
  bool _isUserInitialized = false;
  String _filterType = 'semua'; // hari_ini, minggu_ini, semua
  String _statusFilter = 'semua'; // semua, accepted, rejected, pending

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeInOut));

    _glowAnim = Tween<double>(
      begin: 0.16,
      end: 0.35,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeInOut));
  }

  Future<void> _initializeUserData() async {
    try {
      final currentUserId = _logbookService.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User tidak login');
      }

      _studentId = currentUserId;

      // Get user data from Firestore to get dosenId and mentorId
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _dosenId = userData['dosenId'] ?? 'default_dosen';
        _mentorId = userData['mentorId'] ?? 'default_mentor';
      } else {
        _dosenId = 'default_dosen';
        _mentorId = 'default_mentor';
      }

      setState(() {
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

  @override
  void dispose() {
    _btnController.dispose();
    super.dispose();
  }

  Future<void> _showSuccessDialog() async {
    final textTheme = Theme.of(context).textTheme;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Container with gradient background
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.teal.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  'Logbook Tersimpan',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  'Catatan Logbook Hari Ini Berhasil Disimpan',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.navy.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueBook,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openLogbookDialog() async {
    if (!_isUserInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data masih dimuat...')),
      );
      return;
    }

    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateLogbookScreen(
          studentId: _studentId,
          dosenId: _dosenId,
          mentorId: _mentorId,
        ),
      ),
    );

    if (result == true && mounted) {
      await _showSuccessDialog();
    }
  }

  Stream<List<LogbookModel>> _getFilteredLogbooks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Bulan ini: dari tanggal 1 sampai hari terakhir bulan
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(
      now.year,
      now.month + 1,
      0,
    ); // Hari ke-0 bulan depan = hari terakhir bulan ini

    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    switch (_filterType) {
      case 'bulan_ini':
        return _logbookService
            .getLogbooksByDateRange(
              _studentId,
              monthStart,
              monthEnd.add(const Duration(days: 1)),
            )
            .map((logbooks) => logbooks.toList());
      case 'minggu_ini':
        return _logbookService
            .getLogbooksByDateRange(
              _studentId,
              weekStart,
              weekEnd.add(const Duration(days: 1)),
            )
            .map((logbooks) => logbooks.toList());
      case 'semua':
      default:
        return _logbookService.getStudentLogbooks(_studentId);
    }
  }

  // Filter berdasarkan status
  List<LogbookModel> _filterByStatus(List<LogbookModel> logbooks) {
    if (_statusFilter == 'semua') {
      return logbooks;
    }

    return logbooks.where((logbook) {
      final dosenStatus = logbook.statusDosen.toLowerCase();

      switch (_statusFilter) {
        case 'accepted':
          // Accepted: keduanya approved
          return dosenStatus == 'approved';
        case 'rejected':
          // Rejected: salah satu rejected
          return dosenStatus == 'rejected';
        case 'pending':
          // Pending: tidak rejected dan tidak keduanya approved
          final isRejected = dosenStatus == 'rejected';
          final isAccepted = dosenStatus == 'approved';
          return !isRejected && !isAccepted;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TodayStatusCard(),
            const SizedBox(height: 15),
            AnimatedBuilder(
              animation: _btnController,
              builder: (context, child) {
                final double scale = _scaleAnim.value;
                final double glowOpacity = _glowAnim.value;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blueBook.withOpacity(glowOpacity),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _openLogbookDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueBook,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Catat Logbook Hari Ini',
                    style: t.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Logbook',
                    style: t.titleMedium?.copyWith(
                      color: AppColors.navyDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _FilterChipsRow(
                    selectedFilter: _filterType,
                    onFilterChanged: (filter) {
                      setState(() {
                        _filterType = filter;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    color: AppColors.navy.withOpacity(0.08),
                    height: 24,
                    thickness: 1,
                  ),
                  Text(
                    'Daftar Logbook',
                    style: t.titleMedium?.copyWith(
                      color: AppColors.navyDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Status Filter
                  _StatusFilterChipsRow(
                    selectedFilter: _statusFilter,
                    onFilterChanged: (filter) {
                      setState(() {
                        _statusFilter = filter;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<LogbookModel>>(
                    stream: _getFilteredLogbooks(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      // Apply status filter
                      final allLogbooks = snapshot.data ?? [];
                      final logbooks = _filterByStatus(allLogbooks);

                      if (logbooks.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Tidak ada logbook',
                              style: t.bodyMedium?.copyWith(
                                color: AppColors.navy.withOpacity(0.6),
                              ),
                            ),
                          ),
                        );
                      }

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(
                                      0.0,
                                      0.05,
                                    ), // Start slightly below
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                        child: Column(
                          key: ValueKey<String>(
                            '$_filterType-$_statusFilter-${logbooks.length}',
                          ), // Key changes trigger animation
                          children: List.generate(logbooks.length, (index) {
                            final logbook = logbooks[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 12,
                              ), // Increased spacing
                              child: _LogItemClickable(
                                logbook: logbook,
                                onTap: () => _showLogbookDetail(logbook),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogbookDetail(LogbookModel logbook) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogbookDetailScreen(logbook: logbook),
      ),
    );
  }
}

class _TodayStatusCard extends StatelessWidget {
  const _TodayStatusCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, bottom: 4, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Logbook',
            style: t.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Catat Aktivitas Harian Magang di sini',
            style: t.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const _FilterChipsRow({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          label: 'Semua',
          selected: selectedFilter == 'semua',
          onTap: () => onFilterChanged('semua'),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Minggu Ini',
          selected: selectedFilter == 'minggu_ini',
          onTap: () => onFilterChanged('minggu_ini'),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Bulan Ini',
          selected: selectedFilter == 'bulan_ini',
          onTap: () => onFilterChanged('bulan_ini'),
        ),
      ],
    );
  }
}

class _StatusFilterChipsRow extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const _StatusFilterChipsRow({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Semua',
            selected: selectedFilter == 'semua',
            onTap: () => onFilterChanged('semua'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Disetujui',
            selected: selectedFilter == 'accepted',
            onTap: () => onFilterChanged('accepted'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Ditolak',
            selected: selectedFilter == 'rejected',
            onTap: () => onFilterChanged('rejected'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Menunggu',
            selected: selectedFilter == 'pending',
            onTap: () => onFilterChanged('pending'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withOpacity(0.25),
          ),
        ),
        child: Text(
          label,
          style: t.bodySmall?.copyWith(
            color: selected ? AppColors.navyDark : AppColors.navy,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _LogItemClickable extends StatelessWidget {
  final LogbookModel logbook;
  final VoidCallback onTap;

  const _LogItemClickable({required this.logbook, required this.onTap});

  // Helper method untuk menentukan warna berdasarkan status
  Color _getIconColor() {
    final dosenStatus = logbook.statusDosen.toLowerCase();

    // Jika salah satu rejected, tampilkan merah
    if (dosenStatus == 'rejected') {
      return Colors.red;
    }

    // Jika keduanya approved, tampilkan hijau
    if (dosenStatus == 'approved') {
      return AppColors.greenArrow;
    }

    // Default (pending), tampilkan biru
    return AppColors.blueBook;
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
    final iconColor = _getIconColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withOpacity(0.04), // Subtle shadow
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.navy.withOpacity(0.06)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                // Dynamic background based on status color
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.note_alt_rounded,
                size: 22,
                color: iconColor,
              ), // Rounded icon
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    logbook.judulKegiatan,
                    style: t.bodyMedium?.copyWith(
                      color: AppColors.navyDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(logbook.date),
                    style: t.bodySmall?.copyWith(
                      color: AppColors.navy.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.navy.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
