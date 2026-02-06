import '../../domain/models/attendance_record.dart';

abstract class AttendanceRepository {
  Future<double> getOverallPercent();
  Future<int> getTotalAttended();
  Future<int> getTotalHeld();
  Future<List<AttendanceRecord>> getRecentActivity({String? type});
}

class MockAttendanceRepository implements AttendanceRepository {
  @override
  Future<double> getOverallPercent() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 82;
  }

  @override
  Future<int> getTotalAttended() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 45;
  }

  @override
  Future<int> getTotalHeld() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 55;
  }

  @override
  Future<List<AttendanceRecord>> getRecentActivity({String? type}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      AttendanceRecord(
        id: '1',
        sessionTitle: 'Intro to Data Science',
        date: now.subtract(const Duration(days: 1)),
        time: '09:00 AM',
        isPresent: true,
        sessionType: 'Class',
      ),
      AttendanceRecord(
        id: '2',
        sessionTitle: 'Mastery: Communication',
        date: now.subtract(const Duration(days: 3)),
        time: '02:00 PM',
        isPresent: false,
        sessionType: 'Mastery',
      ),
      AttendanceRecord(
        id: '3',
        sessionTitle: 'Guest Speaker: Tech',
        date: now.subtract(const Duration(days: 5)),
        time: '11:30 AM',
        isPresent: true,
        sessionType: 'Seminar',
      ),
      AttendanceRecord(
        id: '4',
        sessionTitle: 'Software Eng. Lab',
        date: now.subtract(const Duration(days: 6)),
        time: '08:00 AM',
        isPresent: true,
        sessionType: 'Class',
      ),
    ];
  }
}
