/// Base exception for app-level errors. Use for API, validation, or domain errors.
abstract class AppException implements Exception {
  const AppException(this.message, [this.code, this.stackTrace]);

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Thrown when validation fails (e.g. form input).
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code, super.stackTrace]);
}

/// Thrown when a network or API call fails.
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code, super.stackTrace]);
}

/// Thrown when the server returns an error response.
class ServerException extends AppException {
  const ServerException(super.message, [super.code, super.stackTrace]);
}

/// Thrown when auth fails (invalid credentials, expired token, etc.).
class AuthException extends AppException {
  const AuthException(super.message, [super.code, super.stackTrace]);
}
