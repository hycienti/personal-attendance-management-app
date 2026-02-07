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
  static const int _version = 1;

  // our formative Tables
  static const String tableAssignments = 'assignments';
  static const String tableAttendanceRecords = 'attendance_records';


  static Future<AppDatabase> init() async {
    if (_instance != null) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    AppLogger.i('SQLite database path: $path');
    _db = await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
    );
    _instance = AppDatabase._();
    return _instance!;
  }

  static Future<void> _onCreate(Database db, int version) async {
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
    }
    return database.query(
      tableAssignments,
      orderBy: 'created_at DESC',
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
}
