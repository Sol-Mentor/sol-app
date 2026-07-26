import 'package:flutter/material.dart';

import '../../core/theme/sol_colors.dart';

enum SolTab {
  journey,
  today,
  discover,
}

class SolBottomNav extends StatelessWidget {
  const SolBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final SolTab currentTab;
  final ValueChanged<SolTab> onTabSelected;

  static const double _navContentHeight = 47;

  static double heightOf(BuildContext context) {
    return _navContentHeight +
        20 +
        MediaQuery.paddingOf(context).bottom;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SolColors.dawn.withValues(alpha: 0.92),
        border: const Border(top: BorderSide(color: SolColors.hair)),
      ),
      padding: EdgeInsets.only(
        top: 10,
        bottom: MediaQuery.paddingOf(context).bottom + 10,
        left: 8,
        right: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _NavItem(
            label: 'Journey',
            icon: Icons.auto_awesome_outlined,
            isSelected: currentTab == SolTab.journey,
            onTap: () => onTabSelected(SolTab.journey),
          ),
          _NavItem(
            label: 'Today',
            icon: Icons.wb_sunny_outlined,
            isSelected: currentTab == SolTab.today,
            onTap: () => onTabSelected(SolTab.today),
          ),
          _NavItem(
            label: 'Discover',
            icon: Icons.menu_book_outlined,
            isSelected: currentTab == SolTab.discover,
            onTap: () => onTabSelected(SolTab.discover),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected ? SolColors.coralText : SolColors.clayDeep;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
