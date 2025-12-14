import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import '../../../app/app_colors.dart';
import '../data/logbook_validation_models.dart';
import '../data/logbook_validation_service.dart';
import 'logbook_validation_detail_screen.dart';
import '../../auth/data/auth_provider.dart';

class DosenHistoryScreen extends StatefulWidget {
  const DosenHistoryScreen({super.key});

  @override
  State<DosenHistoryScreen> createState() => _DosenHistoryScreenState();
}

class _DosenHistoryScreenState extends State<DosenHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  String _selectedFilter = 'Semua';
  final LogbookValidationService _validationService =
      LogbookValidationService();

  final List<String> _filters = ['Semua', 'Disetujui', 'Ditolak', 'Diproses'];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<LogbookValidationItem> _getFilteredItems(
    List<LogbookValidationItem> allItems,
  ) {
    if (_selectedFilter == 'Semua') return allItems;
    if (_selectedFilter == 'Disetujui') {
      return allItems.where((e) => e.status == LogbookStatus.approved).toList();
    }
    if (_selectedFilter == 'Ditolak') {
      return allItems.where((e) => e.status == LogbookStatus.revision).toList();
    }
    if (_selectedFilter == 'Diproses') {
      return allItems.where((e) => e.status == LogbookStatus.waiting).toList();
    }
    return allItems;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authProvider = context.watch<AuthProvider>();
    final isMentor = authProvider.isMentor;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<List<LogbookValidationItem>>(
          stream: _validationService.getValidationItems(user.uid, isMentor),
          builder: (context, snapshot) {
            // Show content immediately without loading spinner

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final allItems = snapshot.data ?? [];
            final items = _getFilteredItems(allItems);

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Validasi',
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isMentor
                        ? 'Daftar logbook mahasiswa bimbinganmu'
                        : 'Daftar Logbook yang Perlu Kamu Validasi',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.blueGrey,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats Bar
                  _buildStatsBar(textTheme, allItems, isMentor),

                  const SizedBox(height: 20),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: filter,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() => _selectedFilter = filter);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // List with animated filter transitions
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: items.isEmpty
                          ? Center(
                              key: const ValueKey('empty'),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox_rounded,
                                    size: 64,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tidak ada logbook',
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              key: ValueKey('list_$_selectedFilter'),
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 140),
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return _HistoryCard(
                                  item: item,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            LogbookValidationDetailScreen(
                                              item: item,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsBar(
    TextTheme textTheme,
    List<LogbookValidationItem> items,
    bool isMentor,
  ) {
    // Calculate stats from real data
    int approvedCount = items.where((e) => e.isApproved).length;
    int revisionCount = items.where((e) => e.isRevision).length;
    int waitingCount = items.where((e) => e.isWaiting).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.navy.withOpacity(0.85),
            AppColors.blueBook.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            approvedCount.toString(),
            'Disetujui',
            AppColors.greenArrow,
            Icons.check_circle_rounded,
          ),
          _buildStatDivider(),
          _buildStatItem(
            revisionCount.toString(),
            'Ditolak',
            Colors.red,
            Icons.edit_note_rounded,
          ),
          _buildStatDivider(),
          _buildStatItem(
            waitingCount.toString(),
            'Diproses',
            AppColors.blueBook,
            Icons.hourglass_top_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFDFEFD),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.navyDark : Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, required this.onTap});

  final LogbookValidationItem item;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (item.status) {
      case LogbookStatus.approved:
        return AppColors.greenArrow;
      case LogbookStatus.revision:
        return Colors.red;
      case LogbookStatus.waiting:
        return AppColors.blueBook;
    }
  }

  IconData get _statusIcon {
    switch (item.status) {
      case LogbookStatus.approved:
        return Icons.check_circle_rounded;
      case LogbookStatus.revision:
        return Icons.cancel_rounded;
      case LogbookStatus.waiting:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_statusIcon, color: _statusColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.studentName,
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.navyDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.navy.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.dateLabel,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.statusLabel,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
