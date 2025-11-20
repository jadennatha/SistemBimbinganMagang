import 'package:flutter/material.dart';

import '../../app/app_colors.dart';

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({required this.currentIndex, required this.onChanged, super.key});

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _NavItem(
              index: 0,
              currentIndex: currentIndex,
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              onTap: onChanged,
            ),
            _NavItem(
              index: 1,
              currentIndex: currentIndex,
              icon: Icons.edit_note_outlined,
              label: 'Logbook',
              onTap: onChanged,
            ),
            _NavItem(
              index: 2,
              currentIndex: currentIndex,
              icon: Icons.person_outline,
              label: 'Profil',
              onTap: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bool selected = index == currentIndex;
    final Color activeColor = AppColors.blueBook;
    final Color inactiveColor = AppColors.navy.withOpacity(0.6);
    final Color iconColor = selected ? activeColor : inactiveColor;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            color: selected
                ? activeColor.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: iconColor,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
