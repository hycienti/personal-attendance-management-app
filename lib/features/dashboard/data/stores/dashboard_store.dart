import '../../../../core/logging/app_logger.dart';
import '../../domain/models/dashboard_models.dart';

abstract class DashboardStore {
  Future<DashboardStats> getStats();
  Future<List<TodaySession>> getTodaySessions();
  Future<List<UpcomingAssignment>> getUpcomingAssignments();
}

class MockDashboardStore implements DashboardStore {
  @override
  Future<DashboardStats> getStats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    AppLogger.d('DashboardStore.getStats (mocked)');
    return const DashboardStats(
      pendingTasksCount: 4,
      upcomingDueLabel: 'Due Tomorrow',
      attendancePercent: 82,
      attendanceStatus: 'Good Standing',
      attendanceMessage: 'You are above the 75% threshold. Keep it up!',
    );
  }

  @override
  Future<List<TodaySession>> getTodaySessions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [];
  }

  @override
  Future<List<UpcomingAssignment>> getUpcomingAssignments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [];
  }
}
