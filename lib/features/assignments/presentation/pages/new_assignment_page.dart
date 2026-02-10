import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/alu_button.dart';
import '../../../../shared/widgets/alu_text_field.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../../data/stores/assignment_store.dart';
import '../../domain/models/assignment.dart';
import '../view_models/new_assignment_view_model.dart';

class NewAssignmentPage extends StatefulWidget {
  const NewAssignmentPage({super.key, this.editing});

  final Assignment? editing;

  @override
  State<NewAssignmentPage> createState() => _NewAssignmentPageState();
}

class _NewAssignmentPageState extends State<NewAssignmentPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _courseController;
  late final TextEditingController _notesController;
  late AssignmentPriority _priority;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _courseController = TextEditingController(text: e?.courseName ?? '');
    _notesController = TextEditingController(text: e?.notes ?? '');
    _priority = e?.priority ?? AssignmentPriority.medium;
    _dueDate = e?.dueDate;
    if (e?.dueTime != null) {
      final parts = e!.dueTime!.split(':');
      if (parts.length >= 2) {
        _dueTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save(NewAssignmentViewModel vm) async {
    final success = await vm.save(
      title: _titleController.text,
      courseName: _courseController.text.isEmpty ? null : _courseController.text,
      dueDate: _dueDate,
      dueTime: _dueTime != null
          ? '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}'
          : null,
      priority: _priority,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      editing: widget.editing,
    );
    if (!mounted) return;
    if (success) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => NewAssignmentViewModel(
        store: context.read<AssignmentStore>(),
      ),
      child: Builder(
        builder: (ctx) {
          return Scaffold(
            appBar: AppBar(
              leadingWidth: 80,
              leading: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.center,
                  ),
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ),
              title: Text(widget.editing != null ? 'Edit Assignment' : 'New Assignment'),
              centerTitle: true,
              actions: [
                TextButton(
                  onPressed: () async {
                    final vm = ctx.read<NewAssignmentViewModel>();
                    if (vm.validate(_titleController.text)) {
                      await _save(vm);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            body: SafeArea(
          child: ResponsiveContainer(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.screenPadding),
              child: Consumer<NewAssignmentViewModel>(
                builder: (context, vm, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AluTextField(
                        controller: _titleController,
                        label: 'What needs to be done?',
                        hint: 'e.g. Entrepreneurial Leadership Essay',
                        errorText: vm.titleError,
                        onChanged: (_) => vm.validate(_titleController.text),
                      ),
                      const SizedBox(height: 16),
                      AluTextField(
                        controller: _courseController,
                        label: 'Course',
                        hint: 'e.g. Data Science',
                        prefixIcon: const Icon(Icons.school_rounded),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Priority Level',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _PriorityChip(
                              priority: AssignmentPriority.high,
                              label: 'High',
                              icon: Icons.flag_rounded,
                              color: AppColors.priorityHigh,
                              selected: _priority == AssignmentPriority.high,
                              onTap: () =>
                                  setState(() => _priority = AssignmentPriority.high),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _PriorityChip(
                              priority: AssignmentPriority.medium,
                              label: 'Medium',
                              icon: Icons.flag_rounded,
                              color: AppColors.priorityMedium,
                              selected: _priority == AssignmentPriority.medium,
                              onTap: () => setState(
                                  () => _priority = AssignmentPriority.medium),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _PriorityChip(
                              priority: AssignmentPriority.low,
                              label: 'Low',
                              icon: Icons.flag_rounded,
                              color: AppColors.success,
                              selected: _priority == AssignmentPriority.low,
                              onTap: () =>
                                  setState(() => _priority = AssignmentPriority.low),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _dueDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (date != null) setState(() => _dueDate = date);
                              },
                              icon: const Icon(Icons.calendar_today_rounded),
                              label: Text(
                                _dueDate != null
                                    ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                    : 'Due Date',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _dueTime ?? TimeOfDay.now(),
                                );
                                if (time != null) setState(() => _dueTime = time);
                              },
                              icon: const Icon(Icons.schedule_rounded),
                              label: Text(
                                _dueTime != null
                                    ? '${_dueTime!.hour}:${_dueTime!.minute.toString().padLeft(2, '0')}'
                                    : 'Time',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AluTextField(
                        controller: _notesController,
                        label: 'Additional Notes (Optional)',
                        hint: 'Add details...',
                        maxLines: 3,
                        maxLength: 500,
                      ),
                      if (vm.saveError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          vm.saveError!,
                          style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      AluButton(
                        label: widget.editing != null ? 'Save Changes' : 'Create Assignment',
                        icon: Icons.add_task_rounded,
                        loading: vm.isSaving,
                        onPressed: () => _save(vm),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
        },
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.priority,
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final AssignmentPriority priority;
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withValues(alpha: 0.1) : null,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected ? color : null,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
