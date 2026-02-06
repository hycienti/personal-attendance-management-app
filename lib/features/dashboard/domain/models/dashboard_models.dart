import 'package:equatable/equatable.dart';

/// Summary stats for dashboard.
class DashboardStats extends Equatable {
  const DashboardStats({
    this.pendingTasksCount = 0,
    this.upcomingDueLabel,
    this.attendancePercent = 0,
    this.attendanceStatus = 'Good Standing',
    this.attendanceMessage,
  });

  final int pendingTasksCount;
  final String? upcomingDueLabel;
  final double attendancePercent;
  final String attendanceStatus;
  final String? attendanceMessage;

  @override
  List<Object?> get props =>
      [pendingTasksCount, upcomingDueLabel, attendancePercent, attendanceStatus, attendanceMessage];
}

/// A session (class/mastery) for today.
class TodaySession extends Equatable {
  const TodaySession({
    required this.id,
    required this.title,
    required this.timeRange,
    required this.location,
    this.isNow = false,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String timeRange;
  final String location;
  final bool isNow;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, title, timeRange, location, isNow, imageUrl];
}

/// Upcoming assignment for dashboard.
class UpcomingAssignment extends Equatable {
  const UpcomingAssignment({
    required this.id,
    required this.title,
    required this.courseOrModule,
    this.dueLabel,
    this.priority,
  });

  final String id;
  final String title;
  final String courseOrModule;
  final String? dueLabel;
  final String? priority;

  @override
  List<Object?> get props => [id, title, courseOrModule, dueLabel, priority];
}
