import 'package:intl/intl.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../assignments/data/stores/assignment_store.dart';
import '../../../assignments/domain/models/assignment.dart';
import '../../../schedule/data/stores/schedule_store.dart';
import '../../../schedule/domain/models/schedule_session.dart';
import '../../domain/models/dashboard_models.dart';
import 'dashboard_store.dart';

/// Dashboard store that pulls real data from [ScheduleStore] and [AssignmentStore].
class DashboardStoreImpl implements DashboardStore {
  DashboardStoreImpl({
    required ScheduleStore scheduleStore,
    required AssignmentStore assignmentStore,
  })  : _scheduleStore = scheduleStore,
        _assignmentStore = assignmentStore;

  final ScheduleStore _scheduleStore;
  final AssignmentStore _assignmentStore;

  static const int _maxUpcomingAssignments = 10;

  @override
  Future<DashboardStats> getStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final allAssignments = await _assignmentStore.getAssignments(filter: null);
    final pendingCount =
        allAssignments.where((a) => !a.isCompleted).length;
    final upcomingIncomplete = allAssignments
        .where((a) =>
            !a.isCompleted &&
            (a.dueDate == null || !a.dueDate!.isBefore(today)))
        .toList()
      ..sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    final nextDue = upcomingIncomplete.isNotEmpty ? upcomingIncomplete.first : null;
    String? upcomingDueLabel;
    if (nextDue != null && nextDue.dueDate != null) {
      final due = nextDue.dueDate!;
      final dueDay = DateTime(due.year, due.month, due.day);
      final diff = dueDay.difference(today).inDays;
      if (diff == 0) {
        upcomingDueLabel = nextDue.title;
      } else if (diff == 1) {
        upcomingDueLabel = '${nextDue.title} (Tomorrow)';
      } else if (diff < 7) {
        upcomingDueLabel = '${nextDue.title} (In $diff days)';
      } else {
        upcomingDueLabel = '${nextDue.title} (${DateFormat.MMMd().format(due)})';
      }
    } else if (nextDue != null) {
      upcomingDueLabel = nextDue.title;
    }

    double attendancePercent = 0;
    try {
      final weekStartNormalized = DateTime(now.year, now.month, now.day);
      final weekday = now.weekday;
      final start = weekStartNormalized.subtract(Duration(days: weekday - 1));
      attendancePercent =
          await _scheduleStore.getAttendancePercentForWeek(start);
    } catch (e, st) {
      AppLogger.w('DashboardStoreImpl.getStats attendance', e, st);
    }

    const threshold = 75.0;
    final attendanceStatus = attendancePercent >= threshold
        ? 'Good Standing'
        : 'Below threshold';
    final attendanceMessage = attendancePercent >= threshold
        ? 'You are above the ${threshold.toInt()}% threshold. Keep it up!'
        : 'Aim for ${threshold.toInt()}% attendance this week.';

    return DashboardStats(
      pendingTasksCount: pendingCount,
      upcomingDueLabel: upcomingDueLabel,
      attendancePercent: attendancePercent,
      attendanceStatus: attendanceStatus,
      attendanceMessage: attendanceMessage,
    );
  }

  @override
  Future<List<TodaySession>> getTodaySessions() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessions = await _scheduleStore.getSessionsForDay(today);
    final list = sessions.map((s) => _toTodaySession(s, now)).toList();
    list.sort((a, b) => a.timeRange.compareTo(b.timeRange));
    return list;
  }

  @override
  Future<List<UpcomingAssignment>> getUpcomingAssignments() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final all = await _assignmentStore.getAssignments(filter: null);
    final upcoming = all
        .where((a) =>
            !a.isCompleted &&
            (a.dueDate == null || !a.dueDate!.isBefore(today)))
        .toList()
      ..sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    return upcoming
        .take(_maxUpcomingAssignments)
        .map(_toUpcomingAssignment)
        .toList();
  }

  static TodaySession _toTodaySession(ScheduleSession s, DateTime now) {
    final timeRange =
        '${DateFormat('HH:mm').format(s.startTime)} – ${DateFormat('HH:mm').format(s.endTime)}';
    final isNow = (s.startTime.isBefore(now) || s.startTime.isAtSameMomentAs(now)) &&
        s.endTime.isAfter(now);
    return TodaySession(
      id: s.id,
      title: s.title,
      timeRange: timeRange,
      location: s.location ?? '—',
      isNow: isNow,
    );
  }

  static UpcomingAssignment _toUpcomingAssignment(Assignment a) {
    String? dueLabel;
    if (a.dueDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dueDay = DateTime(a.dueDate!.year, a.dueDate!.month, a.dueDate!.day);
      final diff = dueDay.difference(today).inDays;
      if (diff == 0) {
        dueLabel = 'Today';
      } else if (diff == 1) {
        dueLabel = 'Tomorrow';
      } else if (diff < 7) {
        dueLabel = 'In $diff days';
      } else {
        dueLabel = DateFormat.MMMd().format(a.dueDate!);
      }
    }
    return UpcomingAssignment(
      id: a.id,
      title: a.title,
      courseOrModule: a.courseName ?? '—',
      dueLabel: dueLabel,
      priority: a.priority.name,
    );
  }
}
