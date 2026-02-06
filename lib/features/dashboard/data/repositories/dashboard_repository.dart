import '../../../../core/logging/app_logger.dart';
import '../../domain/models/dashboard_models.dart';

/// Repository for dashboard data. Replace with API when ready.
abstract class DashboardRepository {
  Future<DashboardStats> getStats();
  Future<List<TodaySession>> getTodaySessions();
  Future<List<UpcomingAssignment>> getUpcomingAssignments();
}

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardStats> getStats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    AppLogger.d('DashboardRepository.getStats (mocked)');
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
    return const [
      TodaySession(
        id: '1',
        title: 'Entrepreneurial Leadership',
        timeRange: '10:00 - 11:30',
        location: 'Room 304',
        isNow: true,
      ),
      TodaySession(
        id: '2',
        title: 'Data Science',
        timeRange: '13:00 - 15:00',
        location: 'Lab 4',
        isNow: false,
      ),
    ];
  }

  @override
  Future<List<UpcomingAssignment>> getUpcomingAssignments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      UpcomingAssignment(
        id: '1',
        title: 'Data Science Project',
        courseOrModule: 'Module 3: Regression Analysis',
        dueLabel: 'In 2 Days',
        priority: 'high',
      ),
      UpcomingAssignment(
        id: '2',
        title: 'Global Challenges Essay',
        courseOrModule: 'Climate Action Draft',
        dueLabel: 'Friday',
        priority: 'medium',
      ),
      UpcomingAssignment(
        id: '3',
        title: 'Peer Review',
        courseOrModule: 'Leadership Capstone',
        dueLabel: 'Nov 20',
        priority: 'medium',
      ),
    ];
  }
}
