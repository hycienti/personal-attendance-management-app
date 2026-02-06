import 'package:equatable/equatable.dart';

enum AssignmentPriority { high, medium, low }

/// Assignment or task model.
class Assignment extends Equatable {
  const Assignment({
    required this.id,
    required this.title,
    this.courseName,
    this.dueDate,
    this.dueTime,
    this.priority = AssignmentPriority.medium,
    this.isCompleted = false,
    this.notes,
  });

  final String id;
  final String title;
  final String? courseName;
  final DateTime? dueDate;
  final String? dueTime;
  final AssignmentPriority priority;
  final bool isCompleted;
  final String? notes;

  @override
  List<Object?> get props =>
      [id, title, courseName, dueDate, dueTime, priority, isCompleted, notes];
}
