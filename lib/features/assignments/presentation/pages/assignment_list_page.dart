import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/state/auth_session.dart';
import '../../../../shared/widgets/alu_card.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../../domain/models/assignment.dart';
import '../view_models/assignment_list_view_model.dart';

class AssignmentListPage extends StatefulWidget {
  const AssignmentListPage({super.key});

  @override
  State<AssignmentListPage> createState() => _AssignmentListPageState();
}

class _AssignmentListPageState extends State<AssignmentListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthSession>().ensureUserLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        onViewCalendar: () =>
                            context.push(RouteConstants.schedule),
                      ),
                      const SizedBox(height: 16),
                      const _WeeklyProgressCard(),
                      const SizedBox(height: 16),
                      const _TaskSummaryCards(),
                      const SizedBox(height: 16),
                      const _FilterChips(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: true,
                child: Consumer<AssignmentListViewModel>(
                  builder: (context, vm, _) {
                    return vm.state.when(
                      loading: () => const LoadingView(compact: true),
                      success: (list) => list.isEmpty
                          ? const EmptyView(
                              message: 'No assignments',
                              icon: Icons.assignment_rounded,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: list.length,
                              itemBuilder: (context, i) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _AssignmentTile(
                                  assignment: list[i],
                                  onToggle: () =>
                                      vm.toggleComplete(list[i].id),
                                  onTap: () => context.push(
                                    '${RouteConstants.assignments}/${list[i].id}/edit',
                                    extra: list[i],
                                  ),
                                  onDelete: () => vm.deleteAssignment(list[i].id),
                                ),
                              ),
                            ),
                      empty: () => const EmptyView(
                        message: 'No assignments',
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('${RouteConstants.assignments}/new'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.onViewCalendar});

  final VoidCallback? onViewCalendar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<AuthSession>(
      builder: (context, session, _) {
        final name = session.currentUser?.fullName ?? 'User';
        final subtitle = session.currentUser?.studentId != null
            ? 'Student ID: ${session.currentUser!.studentId}'
            : '';
        return Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: const Icon(Icons.person_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, $name', style: theme.textTheme.titleLarge),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
    );
  }
}

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<AssignmentListViewModel>(
      builder: (context, vm, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.priorityHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${vm.weeklyCompletionRate}%',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Completion Rate',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: vm.weeklyCompletionRate / 100,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.show_chart_rounded,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 32,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskSummaryCards extends StatelessWidget {
  const _TaskSummaryCards();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<AssignmentListViewModel>(
      builder: (context, vm, _) {
        return Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.priorityHigh.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.pending_actions_rounded,
                        color: AppColors.priorityHigh,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PENDING',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.priorityHigh,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${vm.pendingCount}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Tasks remaining',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DONE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${vm.completedCount}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Completed',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Consumer<AssignmentListViewModel>(
        builder: (context, vm, _) {
          return Row(
            children: [
              _Chip(
                label: 'All',
                selected: vm.filter == 'all',
                onTap: () => vm.setFilter('all'),
              ),
              const SizedBox(width: 8),
              _Chip(
                label: 'High Priority',
                selected: vm.filter == 'high',
                onTap: () => vm.setFilter('high'),
              ),
              const SizedBox(width: 8),
              _Chip(
                label: 'Medium Priority',
                selected: vm.filter == 'medium',
                onTap: () => vm.setFilter('medium'),
              ),
              const SizedBox(width: 8),
              _Chip(
                label: 'Low Priority',
                selected: vm.filter == 'low',
                onTap: () => vm.setFilter('low'),
              ),
              const SizedBox(width: 8),
              _Chip(
                label: 'Due Soon',
                selected: vm.filter == 'due_soon',
                onTap: () => vm.setFilter('due_soon'),
              ),
              const SizedBox(width: 8),
              _Chip(
                label: 'Done',
                selected: vm.filter == 'done',
                onTap: () => vm.setFilter('done'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({
    required this.assignment,
    required this.onToggle,
    this.onTap,
    this.onDelete,
  });

  final Assignment assignment;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHigh = assignment.priority == AssignmentPriority.high;
    final isMedium = assignment.priority == AssignmentPriority.medium;
    return Dismissible(
      key: Key(assignment.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.priorityHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Remove assignment?'),
            content: Text(
              'Remove "${assignment.title}" from your list?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.priorityHigh,
                ),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      child: AluCard(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
            value: assignment.isCompleted,
            onChanged: (_) => onToggle(),
            activeColor: AppColors.primary,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        assignment.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          decoration: assignment.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isHigh
                            ? AppColors.priorityHigh.withValues(alpha: 0.2)
                            : isMedium
                                ? AppColors.priorityMedium.withValues(alpha: 0.2)
                                : AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isHigh
                            ? 'High'
                            : isMedium
                                ? 'Medium'
                                : 'Low',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isHigh
                              ? AppColors.priorityHigh
                              : isMedium
                                  ? AppColors.priorityMedium
                                  : AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (assignment.courseName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    assignment.courseName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (assignment.dueTime != null || assignment.dueDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        assignment.dueTime ??
                            (assignment.dueDate != null
                                ? 'Due ${assignment.dueDate!.day}/${assignment.dueDate!.month}'
                                : ''),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
