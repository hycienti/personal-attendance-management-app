import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../logging/app_logger.dart';


class AppDatabase {
  AppDatabase._();

  static AppDatabase? _instance;
  static Database? _db;

  static const String _dbName = 'attendance_app.db';
  static const int _version = 4;

  // Tables
  static const String tableUsers = 'users';
  static const String tableSession = 'session';
  static const String tableAssignments = 'assignments';
  static const String tableAttendanceRecords = 'attendance_records';
  static const String tableScheduleSessions = 'schedule_sessions';


  static Future<AppDatabase> init() async {
    if (_instance != null) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    AppLogger.i('SQLite database path: $path');
    _db = await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    _instance = AppDatabase._();
    return _instance!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await _createUsersTable(db);
    await _createSessionTable(db);
    await _createScheduleSessionsTable(db);
    await db.execute('''
      CREATE TABLE $tableAssignments (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        course_name TEXT,
        due_date TEXT,
        due_time TEXT,
        priority TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableAttendanceRecords (
        id TEXT PRIMARY KEY,
        session_title TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        is_present INTEGER NOT NULL,
        session_type TEXT NOT NULL DEFAULT 'Class',
        created_at TEXT
      )
    ''');
    AppLogger.d('SQLite tables created');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createUsersTable(db);
      AppLogger.d('SQLite: users table added in migration');
    }
    if (oldVersion < 3) {
      await _createSessionTable(db);
      AppLogger.d('SQLite: session table added in migration');
    }
    if (oldVersion < 4) {
      await _createScheduleSessionsTable(db);
      AppLogger.d('SQLite: schedule_sessions table added in migration');
    }
  }

  static Future<void> _createSessionTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableSession (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        user_id TEXT
      )
    ''');
    await db.rawInsert(
      'INSERT OR IGNORE INTO $tableSession (id, user_id) VALUES (1, NULL)',
    );
  }

  static Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableUsers (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        full_name TEXT NOT NULL,
        student_id TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON $tableUsers (email)',
    );
  }

  static Future<void> _createScheduleSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableScheduleSessions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        location TEXT,
        is_present INTEGER NOT NULL
      )
    ''');
  }

  static AppDatabase? get instance => _instance;

  // Raw database
  static Database? get db => _db;


  static Future<String?> get databasePath async {
    if (_db == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    return join(dir.path, _dbName);
  }

  /// Close the database 
  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
    _instance = null;
  }


  Future<List<Map<String, dynamic>>> getAssignments({String? filter}) async {
    final database = _db!;
    String? where;
    List<Object?>? whereArgs;
    if (filter == 'done') {
      where = 'is_completed = ?';
      whereArgs = [1];
    } else if (filter == 'high') {
      where = 'priority = ?';
      whereArgs = ['high'];
    } else if (filter == 'medium') {
      where = 'priority = ?';
      whereArgs = ['medium'];
    } else if (filter == 'low') {
      where = 'priority = ?';
      whereArgs = ['low'];
    } else if (filter == 'due_soon') {
      final now = DateTime.now();
      final today = now.toIso8601String().split('T').first;
      final weekFromNow = now.add(const Duration(days: 7)).toIso8601String().split('T').first;
      where = 'is_completed = 0 AND due_date IS NOT NULL AND due_date >= ? AND due_date <= ?';
      whereArgs = [today, weekFromNow];
    }
    return database.query(
      tableAssignments,
      orderBy: "COALESCE(due_date, '9999-12-31') ASC, COALESCE(due_time, '23:59') ASC",
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<Map<String, dynamic>> insertAssignment(Map<String, dynamic> row) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    row['id'] = id;
    row['created_at'] = DateTime.now().toIso8601String();
    await _db!.insert(tableAssignments, row);
    return row;
  }

  Future<void> toggleAssignmentComplete(String id) async {
    final rows = await _db!.query(tableAssignments, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return;
    final current = rows.first['is_completed'] as int? ?? 0;
    await _db!.update(
      tableAssignments,
      {'is_completed': current == 1 ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateAssignment(String id, Map<String, dynamic> row) async {
    await _db!.update(
      tableAssignments,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAssignment(String id) async {
    await _db!.delete(tableAssignments, where: 'id = ?', whereArgs: [id]);
  }


  Future<double> getOverallAttendancePercent() async {
    final r = await _db!.rawQuery(
      'SELECT COUNT(*) AS total, SUM(is_present) AS attended FROM $tableAttendanceRecords',
    );
    final total = (r.first['total'] as int?) ?? 0;
    if (total == 0) return 0;
    final attended = (r.first['attended'] as int?) ?? 0;
    return (attended / total) * 100;
  }

  Future<int> getTotalAttended() async {
    final r = await _db!.rawQuery(
      'SELECT COUNT(*) AS c FROM $tableAttendanceRecords WHERE is_present = 1',
    );
    return (r.first['c'] as int?) ?? 0;
  }

  Future<int> getTotalHeld() async {
    final r = await _db!.rawQuery('SELECT COUNT(*) AS c FROM $tableAttendanceRecords');
    return (r.first['c'] as int?) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getRecentAttendance({String? type, int limit = 20}) async {
    String? where;
    List<Object?>? whereArgs;
    if (type != null && type.isNotEmpty) {
      where = 'session_type = ?';
      whereArgs = [type];
    }
    return _db!.query(
      tableAttendanceRecords,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC, time DESC',
      limit: limit,
    );
  }

  Future<Map<String, dynamic>> insertAttendanceRecord(Map<String, dynamic> row) async {
    final id = row['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
    row['id'] = id;
    row['created_at'] = DateTime.now().toIso8601String();
    await _db!.insert(tableAttendanceRecords, row);
    return row;
  }

  // --- Users (auth) ---

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final rows = await _db!.query(
      tableUsers,
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final rows = await _db!.query(
      tableUsers,
      where: 'id = ?',
      whereArgs: [id],
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, dynamic>> insertUser(Map<String, dynamic> row) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    row['id'] = id;
    row['email'] = (row['email'] as String).trim().toLowerCase();
    row['created_at'] = DateTime.now().toIso8601String();
    await _db!.insert(tableUsers, row);
    return row;
  }

  // --- Session (current user id persisted in DB) ---

  Future<String?> getSessionUserId() async {
    final rows = await _db!.query(
      tableSession,
      columns: ['user_id'],
      where: 'id = ?',
      whereArgs: [1],
    );
    if (rows.isEmpty) return null;
    final v = rows.first['user_id'];
    return v is String ? v : null;
  }

  Future<void> setSessionUserId(String? userId) async {
    await _db!.rawInsert(
      'INSERT OR REPLACE INTO $tableSession (id, user_id) VALUES (1, ?)',
      [userId],
    );
  }

  // --- Schedule Sessions ---

  Future<void> insertScheduleSession(Map<String, dynamic> row) async {
    await _db!.insert(tableScheduleSessions, row);
  }

  Future<List<Map<String, dynamic>>> getScheduleSessionsForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return _db!.query(
      tableScheduleSessions,
      where: 'start_time >= ? AND start_time < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'start_time ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllScheduleSessions() async {
    return _db!.query(
      tableScheduleSessions,
      orderBy: 'start_time ASC',
    );
  }

  Future<void> updateScheduleSession(String id, Map<String, dynamic> row) async {
    await _db!.update(
      tableScheduleSessions,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteScheduleSession(String id) async {
    await _db!.delete(tableScheduleSessions, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleScheduleSessionAttendance(String id) async {
    final rows = await _db!.query(tableScheduleSessions, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return;
    final current = (rows.first['is_present'] as int? ?? 0);
    await _db!.update(
      tableScheduleSessions,
      {'is_present': current == 1 ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
