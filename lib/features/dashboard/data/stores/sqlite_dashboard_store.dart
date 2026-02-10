import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/models/dashboard_models.dart';
import 'dashboard_store.dart';

class SqliteDashboardStore implements DashboardStore {
  SqliteDashboardStore({AppDatabase? db}) : _db = db ?? AppDatabase.instance!;

  final AppDatabase _db;

  @override
  Future<DashboardStats> getStats() async {
    // Get pending tasks count
    final assignments = await _db.getAssignments();
    final pendingCount = assignments.where((a) => (a['is_completed'] as int?) != 1).length;

    // Find upcoming due assignment
    String? upcomingDueLabel;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    for (final a in assignments) {
      if ((a['is_completed'] as int?) == 1) continue;
      final dueDateStr = a['due_date'] as String?;
      if (dueDateStr != null) {
        final dueDate = DateTime.tryParse(dueDateStr);
        if (dueDate != null) {
          if (dueDate.year == tomorrow.year &&
              dueDate.month == tomorrow.month &&
              dueDate.day == tomorrow.day) {
            upcomingDueLabel = a['title'] as String?;
            break;
          }
        }
      }
    }

    // Calculate attendance percentage from schedule_sessions
    final db = AppDatabase.db!;
    final attendanceResult = await db.rawQuery(
      'SELECT COUNT(*) AS total, SUM(is_present) AS attended FROM ${AppDatabase.tableScheduleSessions}',
    );
    final total = (attendanceResult.first['total'] as int?) ?? 0;
    final attended = (attendanceResult.first['attended'] as int?) ?? 0;
    final attendancePercent = total > 0 ? (attended / total) * 100 : 0.0;

    // Calculate weekly attendance (last 7 days)
    final weekStart = now.subtract(const Duration(days: 7));
    final weeklyResult = await db.rawQuery(
      '''SELECT COUNT(*) AS total, SUM(is_present) AS attended 
         FROM ${AppDatabase.tableScheduleSessions} 
         WHERE start_time >= ?''',
      [weekStart.toIso8601String()],
    );
    final weeklyTotal = (weeklyResult.first['total'] as int?) ?? 0;
    final weeklyAttended = (weeklyResult.first['attended'] as int?) ?? 0;
    final weeklyPercent = weeklyTotal > 0 ? (weeklyAttended / weeklyTotal) * 100 : 0.0;

    // Determine attendance status and message
    final status = _getAttendanceStatus(attendancePercent);
    final message = _getAttendanceMessage(attendancePercent);

    return DashboardStats(
      pendingTasksCount: pendingCount,
      upcomingDueLabel: upcomingDueLabel,
      attendancePercent: attendancePercent,
      attendanceStatus: status,
      attendanceMessage: message,
      totalAttended: attended,
      totalHeld: total,
      weeklyAttendancePercent: weeklyPercent,
    );
  }

  String _getAttendanceStatus(double percent) {
    if (percent >= 90) return 'Excellent';
    if (percent >= 75) return 'Good Standing';
    if (percent >= 60) return 'Needs Improvement';
    if (percent >= 40) return 'At Risk';
    return 'Critical';
  }

  String _getAttendanceMessage(double percent) {
    if (percent >= 90) {
      return 'Outstanding! You have excellent attendance.';
    }
    if (percent >= 75) {
      return 'You are above the 75% threshold. Keep it up!';
    }
    if (percent >= 60) {
      return 'Your attendance is below recommended. Try to attend more sessions.';
    }
    if (percent >= 40) {
      return 'Warning: Your attendance is at risk. Please prioritize attending sessions.';
    }
    return 'Critical: Your attendance is very low. Immediate action needed.';
  }

  @override
  Future<List<TodaySession>> getTodaySessions() async {
    final now = DateTime.now();
    final rows = await _db.getScheduleSessionsForDay(now);
    
    return rows.map((row) {
      final startTime = DateTime.parse(row['start_time'] as String);
      final endTime = DateTime.parse(row['end_time'] as String);
      final timeFormat = DateFormat('HH:mm');
      
      // Check if session is happening now
      final isNow = now.isAfter(startTime) && now.isBefore(endTime);
      
      return TodaySession(
        id: row['id'] as String,
        title: row['title'] as String,
        timeRange: '${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}',
        location: row['location'] as String? ?? 'TBD',
        isNow: isNow,
      );
    }).toList();
  }

  @override
  Future<List<UpcomingAssignment>> getUpcomingAssignments() async {
    final assignments = await _db.getAssignments(filter: 'due_soon');
    
    return assignments.take(5).map((row) {
      final dueDateStr = row['due_date'] as String?;
      String? dueLabel;
      if (dueDateStr != null) {
        final dueDate = DateTime.tryParse(dueDateStr);
        if (dueDate != null) {
          dueLabel = _formatDueLabel(dueDate);
        }
      }
      
      return UpcomingAssignment(
        id: row['id'] as String,
        title: row['title'] as String,
        courseOrModule: row['course_name'] as String? ?? 'General',
        dueLabel: dueLabel,
        priority: row['priority'] as String?,
      );
    }).toList();
  }

  String _formatDueLabel(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = due.difference(today).inDays;
    
    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff <= 7) return 'In $diff days';
    return DateFormat('MMM d').format(dueDate);
  }
}
