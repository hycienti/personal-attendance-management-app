import '../../../../core/database/app_database.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/auth/password_hasher.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyCurrentUserId = 'current_user_id';

/// Handles login, create account, logout, and current user via SQLite + SharedPreferences.
class AuthRepository {
  AuthRepository({
    SharedPreferences? prefs,
  }) : _prefs = prefs;

  SharedPreferences? _prefs;
  static SharedPreferences? _staticPrefs;

  static Future<AuthRepository> create() async {
    _staticPrefs ??= await SharedPreferences.getInstance();
    return AuthRepository(prefs: _staticPrefs);
  }

  Future<SharedPreferences> get _prefsAsync async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Returns current logged-in user id or null.
  Future<String?> get currentUserId async {
    final p = await _prefsAsync;
    return p.getString(_keyCurrentUserId);
  }

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
    final p = await _prefsAsync;
    await p.setString(_keyCurrentUserId, user.id);
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
    final p = await _prefsAsync;
    await p.setString(_keyCurrentUserId, user.id);
    AppLogger.i('AuthRepository: account created ${user.email}');
    return user;
  }

  /// Logout: clear session only (user remains in DB).
  Future<void> logout() async {
    final p = await _prefsAsync;
    await p.remove(_keyCurrentUserId);
    AppLogger.i('AuthRepository: user logged out');
  }

  /// Check if any user is logged in.
  Future<bool> get isLoggedIn async => (await currentUserId) != null;
}
