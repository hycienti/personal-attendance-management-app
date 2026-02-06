import '../../domain/models/schedule_session.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleSession>> getSessionsForDay(DateTime day);
  Future<double> getAttendancePercentForWeek(DateTime weekStart);
}

class MockScheduleRepository implements ScheduleRepository {
  @override
  Future<List<ScheduleSession>> getSessionsForDay(DateTime day) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final base = DateTime(day.year, day.month, day.day);
    return [
      ScheduleSession(
        id: '1',
        title: 'Data Science',
        type: SessionType.class_,
        startTime: base.add(const Duration(hours: 9)),
        endTime: base.add(const Duration(hours: 10, minutes: 30)),
        location: 'Room 204',
        isPresent: true,
      ),
      ScheduleSession(
        id: '2',
        title: 'Entrepreneurial Leadership',
        type: SessionType.mastery,
        startTime: base.add(const Duration(hours: 11)),
        endTime: base.add(const Duration(hours: 12, minutes: 30)),
        location: 'Main Hall',
        isPresent: false,
      ),
      ScheduleSession(
        id: '3',
        title: 'Communication for Impact',
        type: SessionType.workshop,
        startTime: base.add(const Duration(hours: 14)),
        endTime: base.add(const Duration(hours: 15, minutes: 30)),
        location: 'Room 3B',
        isPresent: false,
      ),
    ];
  }

  @override
  Future<double> getAttendancePercentForWeek(DateTime weekStart) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 80;
  }
}
