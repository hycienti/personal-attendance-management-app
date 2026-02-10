import '../../../../core/database/app_database.dart';
import '../../domain/models/schedule_session.dart';
import 'schedule_store.dart';

class SqliteScheduleStore implements ScheduleStore {
  SqliteScheduleStore({AppDatabase? db}) : _db = db ?? AppDatabase.instance!;

  final AppDatabase _db;

  static SessionType _parseType(String typeStr) {
    switch (typeStr) {
      case 'class_':
        return SessionType.class_;
      case 'mastery':
        return SessionType.mastery;
      case 'workshop':
        return SessionType.workshop;
      case 'study':
        return SessionType.study;
      case 'psl':
        return SessionType.psl;
      default:
        return SessionType.class_;
    }
  }

  static ScheduleSession _rowToSession(Map<String, dynamic> row) {
    return ScheduleSession(
      id: row['id'] as String,
      title: row['title'] as String,
      type: _parseType(row['type'] as String),
      startTime: DateTime.parse(row['start_time'] as String),
      endTime: DateTime.parse(row['end_time'] as String),
      location: row['location'] as String?,
      isPresent: (row['is_present'] as int? ?? 0) == 1,
    );
  }

  @override
  Future<List<ScheduleSession>> getSessionsForDay(DateTime day) async {
    final rows = await _db.getScheduleSessionsForDay(day);
    return rows.map(_rowToSession).toList();
  }

  @override
  Future<List<ScheduleSession>> getAllSessions() async {
    final rows = await _db.getAllScheduleSessions();
    return rows.map(_rowToSession).toList();
  }

  @override
  Future<double> getAttendancePercentForWeek(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    final db = AppDatabase.db!;
    final rows = await db.query(
      AppDatabase.tableScheduleSessions,
      where: 'start_time >= ? AND start_time < ?',
      whereArgs: [weekStart.toIso8601String(), weekEnd.toIso8601String()],
    );
    if (rows.isEmpty) return 0;
    final present = rows.where((r) => (r['is_present'] as int? ?? 0) == 1).length;
    return (present / rows.length) * 100;
  }

  @override
  Future<void> addSession(ScheduleSession session) async {
    await _db.insertScheduleSession({
      'id': session.id,
      'title': session.title,
      'type': session.type.name,
      'start_time': session.startTime.toIso8601String(),
      'end_time': session.endTime.toIso8601String(),
      'location': session.location,
      'is_present': session.isPresent ? 1 : 0,
    });
  }

  @override
  Future<void> updateSession(ScheduleSession session) async {
    await _db.updateScheduleSession(session.id, {
      'title': session.title,
      'type': session.type.name,
      'start_time': session.startTime.toIso8601String(),
      'end_time': session.endTime.toIso8601String(),
      'location': session.location,
      'is_present': session.isPresent ? 1 : 0,
    });
  }

  @override
  Future<void> deleteSession(String id) async {
    await _db.deleteScheduleSession(id);
  }

  @override
  Future<void> toggleAttendance(String id) async {
    await _db.toggleScheduleSessionAttendance(id);
  }
}
