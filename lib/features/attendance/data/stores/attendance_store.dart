import '../../domain/models/attendance_record.dart';

abstract class AttendanceStore {
  Future<double> getOverallPercent();
  Future<int> getTotalAttended();
  Future<int> getTotalHeld();
  Future<int> getTotalMissed();
  Future<List<AttendanceRecord>> getRecentActivity({String? type, int limit = 20});
  Future<List<AttendanceRecord>> getAllHistory({String? type, bool? isPresent});
}

class MockAttendanceStore implements AttendanceStore {
  final List<AttendanceRecord> _items = [];

  @override
  Future<double> getOverallPercent() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_items.isEmpty) return 0;
    final attended = _items.where((e) => e.isPresent).length;
    return (attended / _items.length) * 100;
  }

  @override
  Future<int> getTotalAttended() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _items.where((e) => e.isPresent).length;
  }

  @override
  Future<int> getTotalHeld() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _items.length;
  }

  @override
  Future<int> getTotalMissed() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _items.where((e) => !e.isPresent).length;
  }

  @override
  Future<List<AttendanceRecord>> getRecentActivity({String? type, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var list = _items;
    if (type != null && type.isNotEmpty) {
      list = _items.where((e) => e.sessionType == type).toList();
    }
    return list.take(limit).toList();
  }

  @override
  Future<List<AttendanceRecord>> getAllHistory({String? type, bool? isPresent}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var list = _items;
    if (type != null && type.isNotEmpty) {
      list = list.where((e) => e.sessionType == type).toList();
    }
    if (isPresent != null) {
      list = list.where((e) => e.isPresent == isPresent).toList();
    }
    return list;
  }
}
