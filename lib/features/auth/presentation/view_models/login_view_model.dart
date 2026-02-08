import 'package:flutter/foundation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/validators/auth_validators.dart';

/// ViewModel for login screen. Validates and authenticates via AuthRepository (SQLite).
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository;

  AuthRepository? _authRepository;
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _submitError;

  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;
  String? get submitError => _submitError;

  void setObscurePassword(bool value) {
    _obscurePassword = value;
    notifyListeners();
  }

  void clearErrors() {
    _emailError = null;
    _passwordError = null;
    _submitError = null;
    notifyListeners();
  }

  bool validate(String email, String password) {
    _emailError = AuthValidators.email(email);
    _passwordError = AuthValidators.password(password);
    final valid = _emailError == null && _passwordError == null;
    notifyListeners();
    return valid;
  }

  /// Returns the logged-in user on success, null otherwise.
  Future<User?> submit(String email, String password) async {
    if (!validate(email, password)) return null;
    _isLoading = true;
    _submitError = null;
    notifyListeners();
    try {
      final repo = _authRepository ?? await AuthRepository.create();
      final user = await repo.login(email, password);
      if (user == null) {
        _submitError = 'Invalid email or password.';
        return null;
      }
      AppLogger.i('Login success: ${user.email}');
      return user;
    } catch (e, st) {
      AppLogger.e('Login failed', e, st);
      _submitError = 'Login failed. Please try again.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
