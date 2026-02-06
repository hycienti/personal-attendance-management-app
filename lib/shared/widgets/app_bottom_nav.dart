import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';

/// Bottom navigation bar for main app shell. Highlights current route.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentPath,
  });

  final String currentPath;

  int _selectedIndex() {
    if (currentPath.startsWith(RouteConstants.assignments)) return 1;
    if (currentPath.startsWith(RouteConstants.schedule)) return 2;
    if (currentPath.startsWith(RouteConstants.attendanceHistory)) return 3;
    if (currentPath.startsWith(RouteConstants.profile)) return 4;
    return 0; // dashboard
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteConstants.dashboard);
        break;
      case 1:
        context.go(RouteConstants.assignments);
        break;
      case 2:
        context.go(RouteConstants.schedule);
        break;
      case 3:
        context.go(RouteConstants.attendanceHistory);
        break;
      case 4:
        context.go(RouteConstants.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedIndex();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.paddingOf(context).bottom + 8,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.dashboard_rounded,
              label: 'Home',
              selected: selected == 0,
              onTap: () => _onTap(context, 0),
            ),
            _NavItem(
              icon: Icons.assignment_rounded,
              label: 'Assignments',
              selected: selected == 1,
              onTap: () => _onTap(context, 1),
            ),
            _NavItem(
              icon: Icons.calendar_month_rounded,
              label: 'Schedule',
              selected: selected == 2,
              onTap: () => _onTap(context, 2),
            ),
            _NavItem(
              icon: Icons.analytics_rounded,
              label: 'History',
              selected: selected == 3,
              onTap: () => _onTap(context, 3),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              selected: selected == 4,
              onTap: () => _onTap(context, 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondaryLight;
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
