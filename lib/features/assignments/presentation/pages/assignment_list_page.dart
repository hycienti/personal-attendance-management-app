import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
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
                                  onTap: () {},
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
              Text('Hello, Sarah', style: theme.textTheme.titleLarge),
              Text(
                "Computing Class of '25",
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
  });

  final Assignment assignment;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHigh = assignment.priority == AssignmentPriority.high;
    final isMedium = assignment.priority == AssignmentPriority.medium;
    return AluCard(
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
                            ? AppColors.error.withValues(alpha: 0.1)
                            : isMedium
                                ? AppColors.warning.withValues(alpha: 0.1)
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
                              ? AppColors.error
                              : isMedium
                                  ? AppColors.warning
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
    );
  }
}
