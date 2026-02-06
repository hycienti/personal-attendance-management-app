import '../../../../core/constants/validation_constants.dart';

/// Client-side validation for auth forms.
abstract final class AuthValidators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationConstants.requiredField;
    }
    if (!ValidationConstants.emailRegex.hasMatch(value.trim())) {
      return ValidationConstants.invalidEmail;
    }
    if (!value.trim().toLowerCase().endsWith(
          ValidationConstants.aluEmailSuffix.toLowerCase(),
        )) {
      return ValidationConstants.aluEmailRequired;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationConstants.requiredField;
    }
    if (value.length < ValidationConstants.minPasswordLength) {
      return ValidationConstants.passwordTooShort;
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return ValidationConstants.requiredField;
    }
    if (value != password) {
      return ValidationConstants.passwordMismatch;
    }
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationConstants.requiredField;
    }
    if (value.trim().length < ValidationConstants.minNameLength) {
      return ValidationConstants.nameTooShort;
    }
    if (value.trim().length > ValidationConstants.maxNameLength) {
      return 'Name must be under ${ValidationConstants.maxNameLength} characters';
    }
    return null;
  }

  static String? studentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationConstants.requiredField;
    }
    final len = value.trim().length;
    if (len < ValidationConstants.minStudentIdLength ||
        len > ValidationConstants.maxStudentIdLength) {
      return ValidationConstants.invalidStudentId;
    }
    return null;
  }
}
