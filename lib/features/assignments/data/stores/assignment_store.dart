import '../../../../core/logging/app_logger.dart';
import '../../domain/models/assignment.dart';

abstract class AssignmentStore {
  Future<List<Assignment>> getAssignments({String? filter});
  Future<Assignment> addAssignment(Assignment assignment);
  Future<Assignment> updateAssignment(Assignment assignment);
  Future<void> toggleComplete(String id);
  Future<void> deleteAssignment(String id);
}

class MockAssignmentStore implements AssignmentStore {
  final List<Assignment> _items = [];

  @override
  Future<List<Assignment>> getAssignments({String? filter}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    AppLogger.d('AssignmentStore.getAssignments filter=$filter');
    if (filter == 'done') {
      return _items.where((e) => e.isCompleted).toList();
    }
    if (filter == 'high') {
      return _items.where((e) => e.priority == AssignmentPriority.high).toList();
    }
    if (filter == 'medium') {
      return _items.where((e) => e.priority == AssignmentPriority.medium).toList();
    }
    if (filter == 'low') {
      return _items.where((e) => e.priority == AssignmentPriority.low).toList();
    }
    if (filter == 'due_soon') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekFromNow = today.add(const Duration(days: 7));
      return _items
          .where((e) =>
              !e.isCompleted &&
              e.dueDate != null &&
              !e.dueDate!.isBefore(today) &&
              !e.dueDate!.isAfter(weekFromNow))
          .toList();
    }
    final sorted = List<Assignment>.from(_items)
      ..sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    return sorted;
  }

  @override
  Future<Assignment> addAssignment(Assignment assignment) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newItem = Assignment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: assignment.title,
      courseName: assignment.courseName,
      dueDate: assignment.dueDate,
      dueTime: assignment.dueTime,
      priority: assignment.priority,
      isCompleted: false,
      notes: assignment.notes,
    );
    _items.insert(0, newItem);
    return newItem;
  }

  @override
  Future<Assignment> updateAssignment(Assignment assignment) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final i = _items.indexWhere((e) => e.id == assignment.id);
    if (i >= 0) _items[i] = assignment;
    return assignment;
  }

  @override
  Future<void> toggleComplete(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final i = _items.indexWhere((e) => e.id == id);
    if (i >= 0) {
      _items[i] = Assignment(
        id: _items[i].id,
        title: _items[i].title,
        courseName: _items[i].courseName,
        dueDate: _items[i].dueDate,
        dueTime: _items[i].dueTime,
        priority: _items[i].priority,
        isCompleted: !_items[i].isCompleted,
        notes: _items[i].notes,
      );
    }
  }

  @override
  Future<void> deleteAssignment(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _items.removeWhere((e) => e.id == id);
  }
}
