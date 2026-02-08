import 'package:flutter/services.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/auth/password_hasher.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyCurrentUserId = 'current_user_id';

/// Handles login, create account, logout, and current user. Session is persisted in the DB
/// (primary). SharedPreferences and in-memory are used as fallback when DB is unavailable
/// or when migrating from prefs-only to DB.
class AuthRepository {
  AuthRepository({
    SharedPreferences? prefs,
  }) : _prefs = prefs;

  SharedPreferences? _prefs;
  static SharedPreferences? _staticPrefs;
  static String? _memoryCurrentUserId;

  static Future<AuthRepository> create() async {
    if (_staticPrefs == null) {
      try {
        _staticPrefs = await SharedPreferences.getInstance();
      } on PlatformException catch (e) {
        AppLogger.w('AuthRepository: SharedPreferences unavailable: $e');
        _staticPrefs = null;
      } catch (e) {
        AppLogger.w('AuthRepository: SharedPreferences failed: $e');
        _staticPrefs = null;
      }
    }
    return AuthRepository(prefs: _staticPrefs);
  }

  /// Read current user id: DB first, then prefs, then in-memory. If we get id from prefs/memory
  /// and DB is available, write it to DB so session is persisted there.
  Future<String?> _getStoredUserId() async {
    final db = AppDatabase.instance;
    if (db != null) {
      try {
        final id = await db.getSessionUserId();
        if (id != null && id.isNotEmpty) return id;
      } catch (e) {
        AppLogger.w('AuthRepository: DB session read failed: $e');
      }
    }
    String? id;
    if (_prefs != null) {
      id = _prefs!.getString(_keyCurrentUserId);
    } else {
      try {
        _prefs ??= await SharedPreferences.getInstance();
        id = _prefs!.getString(_keyCurrentUserId);
      } on PlatformException catch (_) {
        id = _memoryCurrentUserId;
      } catch (_) {
        id = _memoryCurrentUserId;
      }
    }
    if (id != null && db != null) {
      try {
        await db.setSessionUserId(id);
      } catch (_) {}
    }
    return id;
  }

  /// Persist current user id: DB first, then prefs, then in-memory fallback.
  Future<void> _setStoredUserId(String? id) async {
    final db = AppDatabase.instance;
    if (db != null) {
      try {
        await db.setSessionUserId(id);
      } catch (e) {
        AppLogger.w('AuthRepository: DB session write failed: $e');
      }
    }
    if (_prefs != null) {
      if (id != null) {
        await _prefs!.setString(_keyCurrentUserId, id);
      } else {
        await _prefs!.remove(_keyCurrentUserId);
      }
      return;
    }
    try {
      _prefs ??= await SharedPreferences.getInstance();
      if (id != null) {
        await _prefs!.setString(_keyCurrentUserId, id);
      } else {
        await _prefs!.remove(_keyCurrentUserId);
      }
    } on PlatformException catch (_) {
      _memoryCurrentUserId = id;
    } catch (_) {
      _memoryCurrentUserId = id;
    }
  }

  /// Returns current logged-in user id or null.
  Future<String?> get currentUserId async => _getStoredUserId();

  /// Returns current user if logged in, else null.
  Future<User?> getCurrentUser() async {
    final dbInstance = AppDatabase.instance;
    if (dbInstance == null) return null;
    final id = await currentUserId;
    if (id == null) return null;
    final row = await dbInstance.getUserById(id);
    return row != null ? User.fromMap(row) : null;
  }

  /// Login: validate credentials against DB and set session.
  Future<User?> login(String email, String password) async {
    final dbInstance = AppDatabase.instance;
    if (dbInstance == null) {
      AppLogger.w('AuthRepository.login: DB not initialized');
      return null;
    }
    final row = await dbInstance.getUserByEmail(email);
    if (row == null) return null;
    final salt = row['salt'] as String? ?? '';
    final storedHash = row['password_hash'] as String? ?? '';
    if (!PasswordHasher.verify(password, salt, storedHash)) return null;
    final user = User.fromMap(row);
    await _setStoredUserId(user.id);
    AppLogger.i('AuthRepository: user logged in ${user.email}');
    return user;
  }

  /// Create account: insert user into DB and set session. Returns user or null if email exists.
  Future<User?> createAccount({
    required String fullName,
    required String studentId,
    required String email,
    required String password,
  }) async {
    final dbInstance = AppDatabase.instance;
    if (dbInstance == null) {
      AppLogger.w('AuthRepository.createAccount: DB not initialized');
      return null;
    }
    final existing = await dbInstance.getUserByEmail(email);
    if (existing != null) return null;
    final salt = PasswordHasher.generateSalt();
    final passwordHash = PasswordHasher.hash(password, salt);
    final row = await dbInstance.insertUser({
      'email': email.trim().toLowerCase(),
      'password_hash': passwordHash,
      'salt': salt,
      'full_name': fullName.trim(),
      'student_id': studentId.trim(),
    });
    final user = User.fromMap(row);
    await _setStoredUserId(user.id);
    AppLogger.i('AuthRepository: account created ${user.email}');
    return user;
  }

  /// Logout: clear session only (user remains in DB).
  Future<void> logout() async {
    await _setStoredUserId(null);
    AppLogger.i('AuthRepository: user logged out');
  }

  /// Check if any user is logged in.
  Future<bool> get isLoggedIn async => (await currentUserId) != null;
}
