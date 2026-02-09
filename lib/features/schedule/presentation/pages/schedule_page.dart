import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/alu_card.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/responsive_container.dart';
import '../../data/stores/schedule_store.dart';
import '../../domain/models/schedule_session.dart';
import 'new_session_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _selectedDay = DateTime.now();
  List<ScheduleSession> _sessions = [];
  bool _loading = true;
  double _weekAttendance = 0;
  final _store = MockScheduleStore();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final sessions = await _store.getSessionsForDay(_selectedDay);
      final weekStart = _selectedDay.subtract(
        Duration(days: _selectedDay.weekday - 1),
      );
      final percent = await _store.getAttendancePercentForWeek(weekStart);
      setState(() {
        _sessions = sessions;
        _weekAttendance = percent;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekDays = List.generate(7, (i) => _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1)).add(Duration(days: i)));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Weekly Schedule'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _selectedDay = DateTime.now()),
            child: const Text('Today'),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedDay),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () => setState(() {
                            _selectedDay = _selectedDay.subtract(const Duration(days: 7));
                            _load();
                          }),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: () => setState(() {
                            _selectedDay = _selectedDay.add(const Duration(days: 7));
                            _load();
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: weekDays.map((d) {
                    final isSelected = _isSameDay(d, _selectedDay);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => setState(() {
                            _selectedDay = d;
                            _load();
                          }),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('EEE').format(d),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isSelected
                                        ? Colors.white70
                                        : theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                  ),
                                ),
                                Text(
                                  '${d.day}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const LoadingView(compact: true)
                    : SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AluCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.pie_chart_rounded,
                                              color: AppColors.primary, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Attendance this week',
                                            style: theme.textTheme.titleSmall,
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${_weekAttendance.toInt()}%',
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: _weekAttendance / 100,
                                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${DateFormat('EEEE').format(_selectedDay)} Schedule',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._sessions.map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _SessionTile(session: s),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newSession = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NewSessionPage(),
            ),
          );
          if (newSession != null && newSession is ScheduleSession) {
            await _store.addSession(newSession); // Save to database/store
            _load(); // Reload sessions from database and save it
            
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final ScheduleSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeLabel = switch (session.type) {
      SessionType.class_ => 'CLASS',
      SessionType.mastery => 'MASTERY',
      SessionType.workshop => 'WORKSHOP',
      SessionType.study => 'STUDY',
      SessionType.psl => 'PSL',
    };
    return AluCard(
      child: Row(
        children: [
          Column(
            children: [
              Text(
                DateFormat('HH:mm').format(session.startTime),
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: session.isPresent
                      ? AppColors.primary
                      : theme.colorScheme.outline,
                  border: Border.all(
                      color: theme.colorScheme.surface, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    typeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.title,
                  style: theme.textTheme.titleSmall,
                ),
                if (session.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6)),
                      const SizedBox(width: 4),
                      Text(
                        session.location!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm').format(session.endTime)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: session.isPresent,
            onChanged: (_) {},
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
    );
  }
}

