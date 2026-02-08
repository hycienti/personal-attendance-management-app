import 'package:flutter/foundation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

/// Holds the current logged-in user. Load once at app start; update on login/create account; clear on logout.
class AuthSession extends ChangeNotifier {
  AuthSession({AuthRepository? repository}) : _repository = repository;

  AuthRepository? _repository;
  User? _currentUser;
  bool _loaded = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoaded => _loaded;

  /// Load session from persistence (DB first, then SharedPreferences). Call once at app start.
  Future<void> loadSession() async {
    if (_loaded) return;
    try {
      final repo = _repository ?? await AuthRepository.create();
      _repository = repo;
      _currentUser = await repo.getCurrentUser();
    } catch (e, st) {
      AppLogger.w('AuthSession.loadSession failed', e, st);
      _currentUser = null;
    }
    _loaded = true;
    notifyListeners();
  }

  /// Set after successful login or create account.
  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Call before navigating to login on logout.
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  /// If we're logged in (per repo) but currentUser is null, load from repository.
  /// Call from dashboard/profile so the UI always shows the correct user.
  Future<void> ensureUserLoaded() async {
    if (_currentUser != null) return;
    final repo = _repository ?? await AuthRepository.create();
    _repository = repo;
    final user = await repo.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }
}
