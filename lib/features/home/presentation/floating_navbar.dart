import 'package:flutter/material.dart';
import '../../../app/app_colors.dart';
import '../../notification/presentation/notification_badge.dart';

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const List<_NavItemData> items = [
    _NavItemData(
      icon: Icons.grid_view_rounded,
      label: 'Beranda',
      accent1: AppColors.blueBook,
      accent2: AppColors.greenArrow,
    ),
    _NavItemData(
      icon: Icons.menu_book_rounded,
      label: 'Logbook',
      accent1: AppColors.navy,
      accent2: AppColors.blueBook,
    ),
    _NavItemData(
      icon: Icons.notifications_rounded,
      label: 'Notifikasi',
      accent1: AppColors.blueBook,
      accent2: AppColors.greenArrow,
    ),
    _NavItemData(
      icon: Icons.person_rounded,
      label: 'Profil',
      accent1: AppColors.blueGrey,
      accent2: AppColors.blueBook,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final data = items[index];
          final bool selected = index == currentIndex;

          return Expanded(
            child: _NavItem(
              data: data,
              selected: selected,
              onTap: () => onChanged(index),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.label,
    required this.accent1,
    required this.accent2,
  });

  final IconData icon;
  final String label;
  final Color accent1;
  final Color accent2;
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _NavItemData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      value: widget.selected ? 1.0 : 0.0,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(covariant _NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.selected && widget.selected) {
      _controller.forward(from: 0.0);
    } else if (oldWidget.selected && !widget.selected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.selected
        ? AppColors.navyDark
        : AppColors.blueGrey;

    // Check if this is the notification tab (index 2)
    final isNotificationTab = widget.data.label == 'Notifikasi';

    Widget iconWidget = _ColoredIcon(
      data: widget.data,
      selected: widget.selected,
    );

    // Wrap notification icon with badge
    if (isNotificationTab) {
      iconWidget = NotificationBadge(child: iconWidget);
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(height: 4),
            Text(
              widget.data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: textColor,
                fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColoredIcon extends StatelessWidget {
  const _ColoredIcon({required this.data, required this.selected});

  final _NavItemData data;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      return Icon(data.icon, size: 22, color: AppColors.blueGrey);
    }

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [data.accent1, data.accent2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Icon(data.icon, size: 24, color: Colors.white),
    );
  }
}
