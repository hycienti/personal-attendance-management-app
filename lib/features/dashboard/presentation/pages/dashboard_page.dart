import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/state/auth_session.dart';
import '../../../../shared/widgets/alu_card.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../../domain/models/dashboard_models.dart';
import '../view_models/dashboard_view_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthSession>().ensureUserLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final greeting = _greeting(now);
    final dateStr = DateFormat(AppConstants.dateFormatShort).format(now);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
          child: RefreshIndicator(
            onRefresh: () => context.read<DashboardViewModel>().load(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                left: AppConstants.screenPadding,
                right: AppConstants.screenPadding,
                bottom: AppConstants.bottomNavHeight + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Header
                  Consumer<AuthSession>(
                    builder: (context, session, _) {
                      final name = session.currentUser?.fullName ?? 'User';
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$greeting, $name',
                                  style: theme.textTheme.titleLarge,
                                ),
                                Text(
                                  '$dateStr | Week ${_weekOfYear(now)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_rounded),
                            onPressed: () {},
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Low Attendance Alert Banner
                  Consumer<DashboardViewModel>(
                    builder: (context, vm, _) {
                      return vm.statsState.when(
                        loading: () => const SizedBox.shrink(),
                        success: (stats) => stats.attendancePercent < 75 && stats.totalHeld > 0
                            ? _LowAttendanceAlert(stats: stats)
                            : const SizedBox.shrink(),
                        empty: () => const SizedBox.shrink(),
                        error: (_) => const SizedBox.shrink(),
                      );
                    },
                  ),
                  // Stats cards
                  Consumer<DashboardViewModel>(
                    builder: (context, vm, _) {
                      return vm.statsState.when(
                        loading: () => const LoadingView(compact: true),
                        success: (stats) => _StatsCards(stats: stats),
                        empty: () => const SizedBox.shrink(),
                        error: (msg) => ErrorView(
                          message: msg,
                          onRetry: vm.load,
                          compact: true,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Today's sessions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Sessions",
                        style: theme.textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () => context.push(RouteConstants.schedule),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Consumer<DashboardViewModel>(
                    builder: (context, vm, _) {
                      return vm.sessionsState.when(
                        loading: () => const LoadingView(compact: true),
                        success: (sessions) => SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: sessions.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, i) {
                              final s = sessions[i];
                              return _SessionCard(session: s);
                            },
                          ),
                        ),
                        empty: () => EmptyView(
                          message: "No sessions today",
                          icon: Icons.event_available_rounded,
                        ),
                        error: (msg) => ErrorView(
                          message: msg,
                          onRetry: vm.load,
                          compact: true,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Attendance health
                  Text(
                    'Attendance Health',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Consumer<DashboardViewModel>(
                    builder: (context, vm, _) {
                      return vm.statsState.when(
                        loading: () => const LoadingView(compact: true),
                        success: (stats) => _AttendanceHealthCard(stats: stats),
                        empty: () => const SizedBox.shrink(),
                        error: (msg) => ErrorView(
                          message: msg,
                          onRetry: vm.load,
                          compact: true,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Upcoming assignments
                  Text(
                    'Upcoming Assignments',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Consumer<DashboardViewModel>(
                    builder: (context, vm, _) {
                      return vm.assignmentsState.when(
                        loading: () => const LoadingView(compact: true),
                        success: (list) => Column(
                          children: list
                              .map((a) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _AssignmentTile(assignment: a),
                                  ))
                              .toList(),
                        ),
                        empty: () => EmptyView(
                          message: 'No upcoming assignments',
                          icon: Icons.assignment_rounded,
                        ),
                        error: (msg) => ErrorView(
                          message: msg,
                          onRetry: vm.load,
                          compact: true,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _greeting(DateTime now) {
    final h = now.hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  int _weekOfYear(DateTime d) {
    final start = DateTime(d.year, 1, 1);
    return ((d.difference(start).inDays) / 7).floor() + 1;
  }
}

class _LowAttendanceAlert extends StatefulWidget {
  const _LowAttendanceAlert({required this.stats});

  final DashboardStats stats;

  @override
  State<_LowAttendanceAlert> createState() => _LowAttendanceAlertState();
}

class _LowAttendanceAlertState extends State<_LowAttendanceAlert> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final stats = widget.stats;
    final isCritical = stats.attendancePercent < 50;
    final alertColor = isCritical ? AppColors.error : Colors.orange;
    
    // Calculate sessions needed to reach 75%
    final sessionsNeeded = _calculateSessionsNeeded(
      stats.totalAttended,
      stats.totalHeld,
      75,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: alertColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: alertColor.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with dismiss button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Icon(
                    isCritical ? Icons.error_rounded : Icons.warning_rounded,
                    color: alertColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isCritical 
                          ? 'Critical: Attendance Below 50%!' 
                          : 'Warning: Attendance Below 75%',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: alertColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20, color: alertColor),
                    onPressed: () => setState(() => _dismissed = true),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your current attendance is ${stats.attendancePercent.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  if (sessionsNeeded > 0)
                    Text(
                      'Attend the next $sessionsNeeded session${sessionsNeeded > 1 ? 's' : ''} to reach 75%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    )
                  else
                    Text(
                      'Keep attending sessions to improve your attendance.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(RouteConstants.schedule),
                          icon: const Icon(Icons.calendar_today_rounded, size: 16),
                          label: const Text('View Schedule'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: alertColor,
                            side: BorderSide(color: alertColor),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => context.push(RouteConstants.attendanceHistory),
                          icon: const Icon(Icons.bar_chart_rounded, size: 16),
                          label: const Text('View Details'),
                          style: FilledButton.styleFrom(
                            backgroundColor: alertColor,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Calculate how many consecutive sessions user needs to attend to reach target percentage
  int _calculateSessionsNeeded(int attended, int total, double targetPercent) {
    if (total == 0) return 0;
    final currentPercent = (attended / total) * 100;
    if (currentPercent >= targetPercent) return 0;
    
    // Formula: (attended + x) / (total + x) >= target/100
    // Solving for x: x >= (target * total - 100 * attended) / (100 - target)
    final target = targetPercent / 100;
    final numerator = target * total - attended;
    final denominator = 1 - target;
    if (denominator <= 0) return 0;
    
    final sessionsNeeded = (numerator / denominator).ceil();
    return sessionsNeeded > 0 ? sessionsNeeded : 0;
  }
}

class _StatsCards extends StatelessWidget {
  const _StatsCards({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AluCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pending_actions_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  '${stats.pendingTasksCount}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  'Pending Tasks',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AluCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  color: AppColors.aluRed,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  stats.upcomingDueLabel ?? 'Global Challenges',
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  stats.upcomingDueLabel != null ? 'Due Tomorrow' : '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.aluRed,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final TodaySession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 280,
      child: AluCard(
        borderSide: BorderSide(
          color: session.isNow ? AppColors.primary : theme.dividerColor,
          width: session.isNow ? 4 : 1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (session.isNow)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'NOW',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              session.title,
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  session.timeRange,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    session.location,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceHealthCard extends StatelessWidget {
  const _AttendanceHealthCard({required this.stats});

  final DashboardStats stats;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Excellent':
        return AppColors.success;
      case 'Good Standing':
        return AppColors.primary;
      case 'Needs Improvement':
        return Colors.orange;
      case 'At Risk':
        return AppColors.error;
      case 'Critical':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (stats.attendancePercent / 100).clamp(0.0, 1.0);
    final statusColor = _getStatusColor(stats.attendanceStatus);
    
    return AluCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  stats.attendanceStatus,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Main metrics row
          Row(
            children: [
              // Circular progress indicator
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: pct,
                        strokeWidth: 10,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        color: statusColor,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${stats.attendancePercent.toInt()}%',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Overall',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Stats breakdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetricRow(
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.success,
                      label: 'Sessions Attended',
                      value: '${stats.totalAttended}',
                    ),
                    const SizedBox(height: 8),
                    _MetricRow(
                      icon: Icons.event_rounded,
                      iconColor: AppColors.primary,
                      label: 'Total Sessions',
                      value: '${stats.totalHeld}',
                    ),
                    const SizedBox(height: 8),
                    _MetricRow(
                      icon: Icons.trending_up_rounded,
                      iconColor: stats.weeklyAttendancePercent >= 75 
                          ? AppColors.success 
                          : Colors.orange,
                      label: 'This Week',
                      value: '${stats.weeklyAttendancePercent.toInt()}%',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Message
          if (stats.attendanceMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stats.attendanceMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          // View Report button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push(RouteConstants.attendanceHistory),
              icon: const Icon(Icons.bar_chart_rounded, size: 18),
              label: const Text('View Detailed Report'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({required this.assignment});

  final UpcomingAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHigh = assignment.priority == 'high';
    return AluCard(
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isHigh
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isHigh ? Icons.warning_rounded : Icons.edit_note_rounded,
              color: isHigh ? AppColors.error : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  assignment.courseOrModule,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (assignment.dueLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isHigh
                    ? AppColors.error.withValues(alpha: 0.2)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                assignment.dueLabel!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isHigh ? AppColors.error : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
