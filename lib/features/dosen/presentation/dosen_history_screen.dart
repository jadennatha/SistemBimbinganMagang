import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../data/logbook_validation_models.dart';
import 'logbook_validation_detail_screen.dart';

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

  final List<String> _filters = ['Semua', 'Disetujui', 'Revisi', 'Menunggu'];

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

  List<LogbookValidationItem> _getFilteredItems() {
    if (_selectedFilter == 'Semua') return demoLogbookValidationItems;
    if (_selectedFilter == 'Disetujui') {
      return demoLogbookValidationItems
          .where((e) => e.status == LogbookStatus.approved)
          .toList();
    }
    if (_selectedFilter == 'Revisi') {
      return demoLogbookValidationItems
          .where((e) => e.status == LogbookStatus.revision)
          .toList();
    }
    if (_selectedFilter == 'Menunggu') {
      return demoLogbookValidationItems
          .where((e) => e.status == LogbookStatus.waiting)
          .toList();
    }
    return demoLogbookValidationItems;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final items = _getFilteredItems();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Riwayat Validasi',
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Daftar logbook yang sudah kamu validasi',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.blueGrey,
                ),
              ),

              const SizedBox(height: 20),

              // Stats Bar
              _buildStatsBar(textTheme),

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

              // List
              Expanded(
                child: items.isEmpty
                    ? Center(
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
                              'Tidak ada riwayat',
                              style: textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _HistoryCard(
                            item: item,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      LogbookValidationDetailScreen(item: item),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.navy.withOpacity(0.8),
            AppColors.blueBook.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildStatItem('12', 'Disetujui', AppColors.greenArrow),
          _buildDivider(),
          _buildStatItem('3', 'Revisi', Colors.orange),
          _buildDivider(),
          _buildStatItem('5', 'Menunggu', AppColors.blueBook),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.2),
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
        return Colors.orange;
      case LogbookStatus.waiting:
        return AppColors.blueBook;
    }
  }

  IconData get _statusIcon {
    switch (item.status) {
      case LogbookStatus.approved:
        return Icons.check_circle_rounded;
      case LogbookStatus.revision:
        return Icons.replay_rounded;
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
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
                        style: textTheme.bodyMedium?.copyWith(
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
                    color: _statusColor.withOpacity(0.1),
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
