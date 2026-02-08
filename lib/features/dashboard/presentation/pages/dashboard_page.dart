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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (stats.attendancePercent / 100).clamp(0.0, 1.0);
    return AluCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.attendanceStatus,
                  style: theme.textTheme.titleMedium,
                ),
                if (stats.attendanceMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    stats.attendanceMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      context.push(RouteConstants.attendanceHistory),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View Report'),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: AppColors.primary,
                ),
                Text(
                  '${stats.attendancePercent.toInt()}%',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
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
