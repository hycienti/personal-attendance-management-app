import '../../domain/models/schedule_session.dart';

abstract class ScheduleStore {
  Future<List<ScheduleSession>> getSessionsForDay(DateTime day);
  Future<double> getAttendancePercentForWeek(DateTime weekStart);
}

class MockScheduleStore implements ScheduleStore {
  @override
  Future<List<ScheduleSession>> getSessionsForDay(DateTime day) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  @override
  Future<double> getAttendancePercentForWeek(DateTime weekStart) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 0;
  }
}
