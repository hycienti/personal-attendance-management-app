import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/models/attendance_record.dart';
import 'attendance_store.dart';

class SqliteAttendanceStore implements AttendanceStore {
  SqliteAttendanceStore();

  /// Convert schedule session row to AttendanceRecord
  static AttendanceRecord _scheduleRowToRecord(Map<String, dynamic> row) {
    final startTimeStr = row['start_time'] as String? ?? '';
    final startTime = DateTime.tryParse(startTimeStr) ?? DateTime.now();
    return AttendanceRecord(
      id: row['id'] as String,
      sessionTitle: row['title'] as String? ?? '',
      date: startTime,
      time: DateFormat('HH:mm').format(startTime),
      isPresent: (row['is_present'] as int? ?? 0) == 1,
      sessionType: _mapSessionType(row['type'] as String? ?? 'class_'),
    );
  }

  static String _mapSessionType(String type) {
    switch (type) {
      case 'class_':
        return 'Class';
      case 'mastery':
        return 'Mastery';
      case 'workshop':
        return 'Workshop';
      case 'study':
        return 'Study';
      case 'psl':
        return 'PSL';
      default:
        return 'Class';
    }
  }

  @override
  Future<double> getOverallPercent() async {
    // Calculate attendance percentage from schedule_sessions table
    // which is where attendance is actually tracked via toggle
    final db = AppDatabase.db!;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total, SUM(is_present) AS attended FROM ${AppDatabase.tableScheduleSessions}',
    );
    final total = (result.first['total'] as int?) ?? 0;
    if (total == 0) return 0;
    final attended = (result.first['attended'] as int?) ?? 0;
    return (attended / total) * 100;
  }

  @override
  Future<int> getTotalAttended() async {
    // Count attended sessions from schedule_sessions table
    final db = AppDatabase.db!;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM ${AppDatabase.tableScheduleSessions} WHERE is_present = 1',
    );
    return (result.first['c'] as int?) ?? 0;
  }

  @override
  Future<int> getTotalHeld() async {
    // Count total sessions from schedule_sessions table
    final db = AppDatabase.db!;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM ${AppDatabase.tableScheduleSessions}',
    );
    return (result.first['c'] as int?) ?? 0;
  }

  @override
  Future<int> getTotalMissed() async {
    final db = AppDatabase.db!;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM ${AppDatabase.tableScheduleSessions} WHERE is_present = 0',
    );
    return (result.first['c'] as int?) ?? 0;
  }

  @override
  Future<double> getMonthlyPercent() async {
    final db = AppDatabase.db!;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total, SUM(is_present) AS attended '
      'FROM ${AppDatabase.tableScheduleSessions} '
      'WHERE start_time >= ? AND start_time < ?',
      [monthStart.toIso8601String(), nextMonth.toIso8601String()],
    );
    final total = (result.first['total'] as int?) ?? 0;
    if (total == 0) return 0;
    final attended = (result.first['attended'] as int?) ?? 0;
    return (attended / total) * 100;
  }

  @override
  Future<double> getMonthlyProgress() async {
    final db = AppDatabase.db!;
    final now = DateTime.now();

    // Current month
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final curr = await db.rawQuery(
      'SELECT COUNT(*) AS total, SUM(is_present) AS attended '
      'FROM ${AppDatabase.tableScheduleSessions} '
      'WHERE start_time >= ? AND start_time < ?',
      [monthStart.toIso8601String(), nextMonth.toIso8601String()],
    );
    final currTotal = (curr.first['total'] as int?) ?? 0;
    final currAttended = (curr.first['attended'] as int?) ?? 0;
    final currPct = currTotal > 0 ? (currAttended / currTotal) * 100 : 0.0;

    // Previous month
    final prevMonthStart = DateTime(now.year, now.month - 1, 1);
    final prev = await db.rawQuery(
      'SELECT COUNT(*) AS total, SUM(is_present) AS attended '
      'FROM ${AppDatabase.tableScheduleSessions} '
      'WHERE start_time >= ? AND start_time < ?',
      [prevMonthStart.toIso8601String(), monthStart.toIso8601String()],
    );
    final prevTotal = (prev.first['total'] as int?) ?? 0;
    final prevAttended = (prev.first['attended'] as int?) ?? 0;
    final prevPct = prevTotal > 0 ? (prevAttended / prevTotal) * 100 : 0.0;

    return currPct - prevPct;
  }

  @override
  Future<List<AttendanceRecord>> getRecentActivity({String? type, int limit = 20}) async {
    // Get recent sessions from schedule_sessions table
    final db = AppDatabase.db!;
    String? where;
    List<Object?>? whereArgs;
    if (type != null && type.isNotEmpty) {
      where = 'type = ?';
      whereArgs = [type.toLowerCase()];
    }
    final rows = await db.query(
      AppDatabase.tableScheduleSessions,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'start_time DESC',
      limit: limit,
    );
    return rows.map(_scheduleRowToRecord).toList();
  }

  @override
  Future<List<AttendanceRecord>> getAllHistory({String? type, bool? isPresent}) async {
    // Get all attendance history with optional filtering
    final db = AppDatabase.db!;
    final conditions = <String>[];
    final args = <Object?>[];
    
    if (type != null && type.isNotEmpty) {
      conditions.add('type = ?');
      args.add(type.toLowerCase());
    }
    if (isPresent != null) {
      conditions.add('is_present = ?');
      args.add(isPresent ? 1 : 0);
    }
    
    final where = conditions.isNotEmpty ? conditions.join(' AND ') : null;
    
    final rows = await db.query(
      AppDatabase.tableScheduleSessions,
      where: where,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'start_time DESC',
    );
    return rows.map(_scheduleRowToRecord).toList();
  }
}
