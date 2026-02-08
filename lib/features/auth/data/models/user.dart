import 'package:equatable/equatable.dart';

/// Logged-in user (no password). From SQLite users table.
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.studentId,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String fullName;
  final String studentId;
  final String createdAt;

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String,
      studentId: map['student_id'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'student_id': studentId,
        'created_at': createdAt,
      };

  @override
  List<Object?> get props => [id, email, fullName, studentId, createdAt];
}
