import 'package:flutter/foundation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../domain/validators/auth_validators.dart';

/// ViewModel for login screen. Handles validation and submit; ready for API.
class LoginViewModel extends ChangeNotifier {
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

  Future<bool> submit(String email, String password) async {
    if (!validate(email, password)) return false;
    _isLoading = true;
    _submitError = null;
    notifyListeners();
    try {
      // TODO: Replace with real API call
      await Future.delayed(const Duration(milliseconds: 800));
      AppLogger.i('Login attempted for $email (mocked success)');
      return true;
    } catch (e, st) {
      AppLogger.e('Login failed', e, st);
      _submitError = 'Login failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
