/// Validation rules and messages used across the app.
abstract final class ValidationConstants {
  ValidationConstants._();

  // Lengths
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int maxEmailLength = 254;
  static const int minStudentIdLength = 4;
  static const int maxStudentIdLength = 20;
  static const int maxAssignmentTitleLength = 200;
  static const int maxCourseNameLength = 100;
  static const int maxLocationLength = 200;
  static const int maxSessionTitleLength = 150;

  // Patterns (for RegExp)
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String aluEmailSuffix = '@alueducation.com';
  static final RegExp emailRegex = RegExp(emailPattern);

  // Messages
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String aluEmailRequired =
      'Please use your ALU student email (@alueducation.com)';
  static const String passwordTooShort =
      'Password must be at least $minPasswordLength characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String nameTooShort =
      'Name must be at least $minNameLength characters';
  static const String invalidStudentId =
      'Student ID must be $minStudentIdLength–$maxStudentIdLength characters';
  static const String titleTooLong =
      'Title must be under $maxAssignmentTitleLength characters';
  static const String endAfterStart = 'End time must be after start time';
}
