import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../data/logbook_validation_models.dart';
import 'logbook_validation_detail_screen.dart';

class LogbookValidationListScreen extends StatefulWidget {
  const LogbookValidationListScreen({super.key});

  @override
  State<LogbookValidationListScreen> createState() =>
      _LogbookValidationListScreenState();
}

class _LogbookValidationListScreenState
    extends State<LogbookValidationListScreen> {
  LogbookStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final items = _filteredItems();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),

              _SummaryCard(summary: demoLogbookSummary),

              const SizedBox(height: 20),

              _StatusFilterRow(
                current: _filter,
                onChanged: (status) {
                  setState(() {
                    _filter = status;
                  });
                },
              ),

              const SizedBox(height: 10),

              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada logbook untuk filter ini.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _LogbookTile(
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

  List<LogbookValidationItem> _filteredItems() {
    if (_filter == null) return demoLogbookValidationItems;
    return demoLogbookValidationItems
        .where((e) => e.status == _filter)
        .toList();
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final LogbookValidationSummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2FB1E3), Color(0xFF2454B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.16),
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logbook menunggu cek',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tinjau entri dan beri status Disetujui atau Revisi.',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryLine(
            label: 'Menunggu cek',
            count: summary.waitingCount,
            dotColor: const Color(0xFFB4E5FF),
          ),
          _SummaryLine(
            label: 'Perlu revisi',
            count: summary.revisionCount,
            dotColor: const Color(0xFFFFD18A),
          ),
          _SummaryLine(
            label: 'Sudah disetujui',
            count: summary.approvedCount,
            dotColor: const Color(0xFFB5F0BE),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.count,
    required this.dotColor,
  });

  final String label;
  final int count;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$count entri',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterRow extends StatelessWidget {
  const _StatusFilterRow({required this.current, required this.onChanged});

  final LogbookStatus? current;
  final ValueChanged<LogbookStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        _FilterChip(
          label: 'Menunggu',
          selected: current == LogbookStatus.waiting,
          onTap: () => onChanged(LogbookStatus.waiting),
          textTheme: textTheme,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Revisi',
          selected: current == LogbookStatus.revision,
          onTap: () => onChanged(LogbookStatus.revision),
          textTheme: textTheme,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Disetujui',
          selected: current == LogbookStatus.approved,
          onTap: () => onChanged(LogbookStatus.approved),
          textTheme: textTheme,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Semua',
          selected: current == null,
          onTap: () => onChanged(null),
          textTheme: textTheme,
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.textTheme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
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
          style: textTheme.bodySmall?.copyWith(
            color: selected ? AppColors.navyDark : Colors.white,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _LogbookTile extends StatelessWidget {
  const _LogbookTile({required this.item, required this.onTap});

  final LogbookValidationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Color statusColor;
    switch (item.status) {
      case LogbookStatus.approved:
        statusColor = AppColors.greenArrow;
        break;
      case LogbookStatus.revision:
        statusColor = Colors.orange;
        break;
      case LogbookStatus.waiting:
      default:
        statusColor = AppColors.blueBook;
        break;
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blueBook.withOpacity(0.08),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.blueBook,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.navyDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.navy.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.dateLabel,
                      style: textTheme.bodySmall?.copyWith(
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
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.statusLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
