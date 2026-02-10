import '../../domain/models/schedule_session.dart';

abstract class ScheduleStore {
  Future<List<ScheduleSession>> getSessionsForDay(DateTime day);
  Future<List<ScheduleSession>> getAllSessions();
  Future<double> getAttendancePercentForWeek(DateTime weekStart);
  Future<void> addSession(ScheduleSession session);
  Future<void> updateSession(ScheduleSession session);
  Future<void> deleteSession(String id);
  Future<void> toggleAttendance(String id);
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
  Future<List<ScheduleSession>> getAllSessions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final sorted = List<ScheduleSession>.from(_sessions)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return sorted;
  }

  @override
  Future<double> getAttendancePercentForWeek(DateTime weekStart) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_sessions.isEmpty) return 0;
    final weekEnd = weekStart.add(const Duration(days: 7));
    final weekSessions = _sessions.where((s) =>
      !s.startTime.isBefore(weekStart) && s.startTime.isBefore(weekEnd),
    ).toList();
    if (weekSessions.isEmpty) return 0;
    final present = weekSessions.where((s) => s.isPresent).length;
    return (present / weekSessions.length) * 100;
  }

  @override
  Future<void> addSession(ScheduleSession session) async {
    _sessions.add(session);
  }

  @override
  Future<void> updateSession(ScheduleSession session) async {
    final i = _sessions.indexWhere((s) => s.id == session.id);
    if (i >= 0) _sessions[i] = session;
  }

  @override
  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> toggleAttendance(String id) async {
    final i = _sessions.indexWhere((s) => s.id == id);
    if (i >= 0) {
      final s = _sessions[i];
      _sessions[i] = ScheduleSession(
        id: s.id,
        title: s.title,
        type: s.type,
        startTime: s.startTime,
        endTime: s.endTime,
        location: s.location,
        isPresent: !s.isPresent,
      );
    }
  }
}
