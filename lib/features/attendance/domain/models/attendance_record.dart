import 'package:equatable/equatable.dart';

/// A single attendance record (session + status).
class AttendanceRecord extends Equatable {
  const AttendanceRecord({
    required this.id,
    required this.sessionTitle,
    required this.date,
    required this.time,
    required this.isPresent,
    this.sessionType = 'Class',
  });

  final String id;
  final String sessionTitle;
  final DateTime date;
  final String time;
  final bool isPresent;
  final String sessionType;

  @override
  List<Object?> get props => [id, sessionTitle, date, time, isPresent, sessionType];
}
