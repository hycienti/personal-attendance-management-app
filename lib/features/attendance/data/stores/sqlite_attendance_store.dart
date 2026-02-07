import '../../../../core/database/app_database.dart';
import '../../domain/models/attendance_record.dart';
import 'attendance_store.dart';

class SqliteAttendanceStore implements AttendanceStore {
  SqliteAttendanceStore({AppDatabase? db}) : _db = db ?? AppDatabase.instance!;

  final AppDatabase _db;

  static AttendanceRecord _rowToRecord(Map<String, dynamic> row) {
    final dateStr = row['date'] as String? ?? '';
    final date = DateTime.tryParse(dateStr) ?? DateTime.now();
    return AttendanceRecord(
      id: row['id'] as String,
      sessionTitle: row['session_title'] as String? ?? '',
      date: date,
      time: row['time'] as String? ?? '',
      isPresent: (row['is_present'] as int? ?? 0) == 1,
      sessionType: row['session_type'] as String? ?? 'Class',
    );
  }

  @override
  Future<double> getOverallPercent() async {
    return _db.getOverallAttendancePercent();
  }

  @override
  Future<int> getTotalAttended() async {
    return _db.getTotalAttended();
  }

  @override
  Future<int> getTotalHeld() async {
    return _db.getTotalHeld();
  }

  @override
  Future<List<AttendanceRecord>> getRecentActivity({String? type}) async {
    final rows = await _db.getRecentAttendance(type: type);
    return rows.map(_rowToRecord).toList();
  }
}
