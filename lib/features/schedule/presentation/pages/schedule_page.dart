import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/alu_card.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/responsive_container.dart';
import 'package:provider/provider.dart';

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
  List<ScheduleSession> _allSessions = [];
  bool _loading = true;
  double _weekAttendance = 0;
  ScheduleStore? _store;
  bool _showAll = false; // false = weekly view, true = all sessions

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_store == null) {
      _store = context.read<ScheduleStore>();
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final sessions = await _store!.getSessionsForDay(_selectedDay);
      final allSessions = await _store!.getAllSessions();
      final weekStart = _selectedDay.subtract(
        Duration(days: _selectedDay.weekday - 1),
      );
      final percent = await _store!.getAttendancePercentForWeek(weekStart);
      setState(() {
        _sessions = sessions;
        _allSessions = allSessions;
        _weekAttendance = percent;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleAttendance(String id) async {
    await _store!.toggleAttendance(id);
    _load();
  }

  Future<void> _deleteSession(String id) async {
    await _store!.deleteSession(id);
    _load();
  }

  Future<void> _openNewSession() async {
    final result = await Navigator.of(context).push<ScheduleSession>(
      MaterialPageRoute(
        builder: (_) => Provider<ScheduleStore>.value(
          value: _store!,
          child: NewSessionPage(initialDate: _selectedDay),
        ),
      ),
    );
    if (result != null) _load();
  }

  Future<void> _openEditSession(ScheduleSession session) async {
    final result = await Navigator.of(context).push<ScheduleSession>(
      MaterialPageRoute(
        builder: (_) => Provider<ScheduleStore>.value(
          value: _store!,
          child: NewSessionPage(editing: session),
        ),
      ),
    );
    if (result != null) _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekDays = List.generate(
      7,
      (i) => _selectedDay
          .subtract(Duration(days: _selectedDay.weekday - 1))
          .add(Duration(days: i)),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Schedule'),
        actions: [
          if (!_showAll)
            TextButton(
              onPressed: () {
                setState(() => _selectedDay = DateTime.now());
                _load();
              },
              child: const Text('Today'),
            ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // View toggle: Weekly / All Sessions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showAll = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_showAll ? AppColors.cardDark : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Weekly',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: !_showAll
                                    ? Colors.white
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: !_showAll ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _showAll = true);
                            _load();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _showAll ? AppColors.cardDark : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'All Sessions',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: _showAll
                                    ? Colors.white
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: _showAll ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Weekly view controls (only when in weekly mode)
              if (!_showAll) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedDay),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded),
                            onPressed: () {
                              setState(() {
                                _selectedDay = _selectedDay
                                    .subtract(const Duration(days: 7));
                              });
                              _load();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded),
                            onPressed: () {
                              setState(() {
                                _selectedDay =
                                    _selectedDay.add(const Duration(days: 7));
                              });
                              _load();
                            },
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
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedDay = d);
                              _load();
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Column(
                                children: [
                                  Text(
                                    DateFormat('EEE').format(d),
                                    style:
                                        theme.textTheme.labelSmall?.copyWith(
                                      color: isSelected
                                          ? Colors.white70
                                          : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  Text(
                                    '${d.day}',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
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
              ],

              // Content
              Expanded(
                child: _loading
                    ? const LoadingView(compact: true)
                    : _showAll
                        ? _buildAllSessionsList(theme)
                        : _buildWeeklyView(theme),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewSession,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeeklyView(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attendance card
          AluCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pie_chart_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Attendance this week',
                            style: theme.textTheme.titleSmall),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_weekAttendance.toInt()}%',
                        style: theme.textTheme.labelLarge?.copyWith(
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

          // Day label
          Text(
            '${DateFormat('EEEE').format(_selectedDay)} Schedule',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),

          // Sessions or empty state
          if (_sessions.isEmpty)
            _buildEmptyState(theme, 'No sessions scheduled', 'Tap + to add a session')
          else
            ..._sessions.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SessionTile(
                  session: s,
                  onToggleAttendance: () => _toggleAttendance(s.id),
                  onTap: () => _openEditSession(s),
                  onDelete: () => _deleteSession(s.id),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAllSessionsList(ThemeData theme) {
    if (_allSessions.isEmpty) {
      return _buildEmptyState(
        theme,
        'No sessions found',
        'You haven\'t scheduled any sessions yet',
      );
    }

    // Group sessions by date
    final grouped = <String, List<ScheduleSession>>{};
    for (final s in _allSessions) {
      final key = DateFormat('yyyy-MM-dd').format(s.startTime);
      grouped.putIfAbsent(key, () => []).add(s);
    }
    final sortedKeys = grouped.keys.toList()..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          AluCard(
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_allSessions.length} session${_allSessions.length == 1 ? '' : 's'} across ${sortedKeys.length} day${sortedKeys.length == 1 ? '' : 's'}',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sessions grouped by date
          for (final dateKey in sortedKeys) ...[
            _buildDateHeader(theme, DateTime.parse(dateKey)),
            const SizedBox(height: 8),
            ...grouped[dateKey]!.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SessionTile(
                  session: s,
                  showDate: true,
                  onToggleAttendance: () => _toggleAttendance(s.id),
                  onTap: () => _openEditSession(s),
                  onDelete: () async {
                    await _deleteSession(s.id);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildDateHeader(ThemeData theme, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final tomorrow = today.add(const Duration(days: 1));

    String label;
    if (dateOnly == today) {
      label = 'Today — ${DateFormat('EEEE, MMM d').format(date)}';
    } else if (dateOnly == tomorrow) {
      label = 'Tomorrow — ${DateFormat('EEEE, MMM d').format(date)}';
    } else {
      label = DateFormat('EEEE, MMM d, yyyy').format(date);
    }

    final isPast = dateOnly.isBefore(today);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dateOnly == today
                  ? AppColors.primary
                  : isPast
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                      : AppColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: dateOnly == today
                  ? AppColors.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: dateOnly == today ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.onToggleAttendance,
    this.onTap,
    this.onDelete,
    this.showDate = false,
  });

  final ScheduleSession session;
  final VoidCallback onToggleAttendance;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDate;

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

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.priorityHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Remove session?'),
            content: Text('Remove "${session.title}" from your schedule?'),
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
          children: [
            // Time and status dot
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
                        ? AppColors.success
                        : theme.colorScheme.outline,
                    border: Border.all(
                        color: theme.colorScheme.surface, width: 2),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
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

            // Present/Absent toggle
            Switch(
              value: session.isPresent,
              onChanged: (_) => onToggleAttendance(),
              activeTrackColor: AppColors.success.withValues(alpha: 0.5),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.success;
                }
                return null;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
