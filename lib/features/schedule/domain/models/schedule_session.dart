import 'package:equatable/equatable.dart';

enum SessionType { class_, mastery, workshop, study, psl }

/// A scheduled session (class, mastery, etc.).
class ScheduleSession extends Equatable {
  const ScheduleSession({
    required this.id,
    required this.title,
    required this.type,
    required this.startTime,
    required this.endTime,
    this.location,
    this.isPresent = false,
  });

  final String id;
  final String title;
  final SessionType type;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final bool isPresent;

  @override
  List<Object?> get props => [id, title, type, startTime, endTime, location, isPresent];
}
