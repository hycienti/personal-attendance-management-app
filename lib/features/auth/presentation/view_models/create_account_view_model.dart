import 'package:flutter/foundation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/validators/auth_validators.dart';

/// ViewModel for create account screen. Persists user to SQLite via AuthRepository.
class CreateAccountViewModel extends ChangeNotifier {
  CreateAccountViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository;

  AuthRepository? _authRepository;
  String? _fullNameError;
  String? _studentIdError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _submitError;

  String? get fullNameError => _fullNameError;
  String? get studentIdError => _studentIdError;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirm => _obscureConfirm;
  bool get isLoading => _isLoading;
  String? get submitError => _submitError;

  void setObscurePassword(bool value) {
    _obscurePassword = value;
    notifyListeners();
  }

  void setObscureConfirm(bool value) {
    _obscureConfirm = value;
    notifyListeners();
  }

  void clearErrors() {
    _fullNameError = null;
    _studentIdError = null;
    _emailError = null;
    _passwordError = null;
    _confirmPasswordError = null;
    _submitError = null;
    notifyListeners();
  }

  bool validate({
    required String fullName,
    required String studentId,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    _fullNameError = AuthValidators.fullName(fullName);
    _studentIdError = AuthValidators.studentId(studentId);
    _emailError = AuthValidators.email(email);
    _passwordError = AuthValidators.password(password);
    _confirmPasswordError =
        AuthValidators.confirmPassword(confirmPassword, password);
    final valid = _fullNameError == null &&
        _studentIdError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
    notifyListeners();
    return valid;
  }

  Future<bool> submit({
    required String fullName,
    required String studentId,
    required String email,
    required String password,
  }) async {
    if (!validate(
      fullName: fullName,
      studentId: studentId,
      email: email,
      password: password,
      confirmPassword: password,
    )) {
      return false;
    }
    _isLoading = true;
    _submitError = null;
    notifyListeners();
    try {
      final repo = _authRepository ?? await AuthRepository.create();
      final user = await repo.createAccount(
        fullName: fullName,
        studentId: studentId,
        email: email,
        password: password,
      );
      if (user == null) {
        _submitError = 'An account with this email already exists.';
        return false;
      }
      AppLogger.i('Create account success: ${user.email}');
      return true;
    } catch (e, st) {
      AppLogger.e('Create account failed', e, st);
      _submitError = 'Registration failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
