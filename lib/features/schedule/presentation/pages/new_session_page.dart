import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/validation_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/alu_button.dart';
import '../../../../shared/widgets/alu_card.dart';
import '../../../../shared/widgets/alu_text_field.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../../data/stores/schedule_store.dart';
import '../../domain/models/schedule_session.dart';

class NewSessionPage extends StatefulWidget {
  const NewSessionPage({super.key, this.initialDate, this.editing});

  /// If provided, the form date defaults to this day (from the schedule page).
  final DateTime? initialDate;

  /// If provided, the form is in edit mode with fields pre-filled.
  final ScheduleSession? editing;

  @override
  State<NewSessionPage> createState() => _NewSessionPageState();
}

class _NewSessionPageState extends State<NewSessionPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late SessionType _sessionType;
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _enableAttendance = true;
  bool _saving = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e != null) {
      _titleController = TextEditingController(text: e.title);
      _locationController = TextEditingController(text: e.location ?? '');
      _sessionType = e.type;
      _date = e.startTime;
      _startTime = TimeOfDay.fromDateTime(e.startTime);
      _endTime = TimeOfDay.fromDateTime(e.endTime);
    } else {
      _titleController = TextEditingController();
      _locationController = TextEditingController();
      _sessionType = SessionType.class_;
      _date = widget.initialDate ?? DateTime.now();
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay(
        hour: (TimeOfDay.now().hour + 1) % 24,
        minute: TimeOfDay.now().minute,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ValidationConstants.requiredField)),
      );
      return;
    }
    setState(() => _saving = true);

    final session = ScheduleSession(
      id: widget.editing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      type: _sessionType,
      startTime: DateTime(
        _date.year,
        _date.month,
        _date.day,
        _startTime.hour,
        _startTime.minute,
      ),
      endTime: DateTime(
        _date.year,
        _date.month,
        _date.day,
        _endTime.hour,
        _endTime.minute,
      ),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      isPresent: widget.editing?.isPresent ?? false,
    );

    try {
      final store = context.read<ScheduleStore>();
      if (_isEditing) {
        await store.updateSession(session);
      } else {
        await store.addSession(session);
      }
      setState(() => _saving = false);
      if (!mounted) return;
      Navigator.of(context).pop(session);
    } catch (e) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save session: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_isEditing ? 'Edit Session' : 'New Session'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── SESSION DETAILS ──
                Text(
                  'SESSION DETAILS',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                AluTextField(
                  controller: _titleController,
                  label: 'Session Title *',
                  hint: 'e.g., Leadership Lab Review',
                ),
                const SizedBox(height: 20),
                Text(
                  'Session Type',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                _SessionTypeSelector(
                  selected: _sessionType,
                  onChanged: (t) => setState(() => _sessionType = t),
                ),

                const SizedBox(height: 32),

                // ── SCHEDULE & LOGISTICS ──
                Text(
                  'SCHEDULE & LOGISTICS',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Date
                Text('Date', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                _DateField(
                  date: _date,
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setState(() => _date = d);
                  },
                ),
                const SizedBox(height: 20),

                // Start Time / End Time
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start Time', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 8),
                          _TimeField(
                            label: _formatTime(_startTime),
                            onTap: () async {
                              final t = await showTimePicker(
                                context: context,
                                initialTime: _startTime,
                              );
                              if (t != null) setState(() => _startTime = t);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('End Time', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 8),
                          _TimeField(
                            label: _formatTime(_endTime),
                            onTap: () async {
                              final t = await showTimePicker(
                                context: context,
                                initialTime: _endTime,
                              );
                              if (t != null) setState(() => _endTime = t);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Location
                AluTextField(
                  controller: _locationController,
                  label: 'Location (Optional)',
                  hint: 'Room name or Link',
                  prefixIcon: const Icon(Icons.location_on_rounded),
                ),

                const SizedBox(height: 24),

                // Enable Attendance toggle
                AluCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.how_to_reg_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enable Attendance',
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              'Track student check-ins via QR code',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _enableAttendance,
                        onChanged: (v) =>
                            setState(() => _enableAttendance = v),
                        activeTrackColor:
                            AppColors.primary.withValues(alpha: 0.5),
                        thumbColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.primary;
                          }
                          return null;
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Schedule button
                AluButton(
                  label: _isEditing ? 'Save Changes' : 'Schedule Session',
                  icon: Icons.event_available_rounded,
                  loading: _saving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Segmented toggle for session types (Class, Mastery, Study, PSL).
class _SessionTypeSelector extends StatelessWidget {
  const _SessionTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  final SessionType selected;
  final ValueChanged<SessionType> onChanged;

  static const _types = [
    (SessionType.class_, 'Class'),
    (SessionType.mastery, 'Mastery'),
    (SessionType.study, 'Study'),
    (SessionType.psl, 'PSL'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: _types.map((entry) {
          final isSelected = selected == entry.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(entry.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cardDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  entry.$2,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Tappable date field matching the design.
class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          color: theme.inputDecorationTheme.fillColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('MM/dd/yyyy').format(date),
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Icon(
              Icons.calendar_month_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tappable time field matching the design.
class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          color: theme.inputDecorationTheme.fillColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: theme.textTheme.bodyLarge),
            ),
            Icon(
              Icons.schedule_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
