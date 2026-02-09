import '../../domain/models/schedule_session.dart';

abstract class ScheduleStore {
  Future<List<ScheduleSession>> getSessionsForDay(DateTime day);
  Future<double> getAttendancePercentForWeek(DateTime weekStart);
  Future<void> addSession(ScheduleSession session);
}

class MockScheduleStore implements ScheduleStore {
  final List<ScheduleSession> _sessions = [];

  @override
  Future<List<ScheduleSession>> getSessionsForDay(DateTime day) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _sessions.where((s) =>
      s.startTime.year == day.year &&
      s.startTime.month == day.month &&
      s.startTime.day == day.day
    ).toList();
  }

  @override
  Future<double> getAttendancePercentForWeek(DateTime weekStart) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 0;
  }

  @override
  Future<void> addSession(ScheduleSession session) async {
    _sessions.add(session);
  }
}
