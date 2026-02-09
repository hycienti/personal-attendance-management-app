import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/validation_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/alu_button.dart';
import '../../../../shared/widgets/alu_card.dart';
import '../../../../shared/widgets/alu_text_field.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../../domain/models/schedule_session.dart';

class NewSessionPage extends StatefulWidget {
  const NewSessionPage({super.key});

  @override
  State<NewSessionPage> createState() => _NewSessionPageState();
}

class _NewSessionPageState extends State<NewSessionPage> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  SessionType _sessionType = SessionType.class_;
  DateTime _date = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);
  bool _enableAttendance = true;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
  if (_titleController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(ValidationConstants.requiredField)),
    );
    return;
  }
  setState(() => _saving = true);
  await Future.delayed(const Duration(milliseconds: 500));
  setState(() => _saving = false);
  if (!mounted) return;

  // Create a new ScheduleSession object
  final newSession = ScheduleSession(
    id: DateTime.now().millisecondsSinceEpoch.toString(), // Provide a unique id
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
    isPresent: false,
  );

  Navigator.of(context).pop(newSession);
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('New Session'),
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
                Text(
                  'Session Details',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                AluTextField(
                  controller: _titleController,
                  label: 'Session Title *',
                  hint: 'e.g., Leadership Lab Review',
                ),
                const SizedBox(height: 16),
                Text(
                  'Session Type',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: SessionType.values.map((t) {
                      final label = switch (t) {
                        SessionType.class_ => 'Class',
                        SessionType.mastery => 'Mastery',
                        SessionType.workshop => 'Workshop',
                        SessionType.study => 'Study',
                        SessionType.psl => 'PSL',
                      };
                      final selected = _sessionType == t;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(label),
                          selected: selected,
                          onSelected: (_) => setState(() => _sessionType = t),
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Schedule & Logistics',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                AluTextField(
                  controller: _locationController,
                  label: 'Location (Optional)',
                  hint: 'Room name or Link',
                  prefixIcon: const Icon(Icons.location_on_rounded),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (d != null) setState(() => _date = d);
                        },
                        icon: const Icon(Icons.calendar_month_rounded),
                        label: Text(
                          '${_date.day}/${_date.month}/${_date.year}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: _startTime,
                          );
                          if (t != null) setState(() => _startTime = t);
                        },
                        icon: const Icon(Icons.schedule_rounded),
                        label: Text(
                          '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: _endTime,
                          );
                          if (t != null) setState(() => _endTime = t);
                        },
                        icon: const Icon(Icons.schedule_rounded),
                        label: Text(
                          '${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AluCard(
                  child: Row(
                    children: [
                      Icon(Icons.how_to_reg_rounded,
                          color: AppColors.primary, size: 28),
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
                        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                        thumbColor: WidgetStateProperty.resolveWith((states) {
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
                AluButton(
                  label: 'Schedule Session',
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
