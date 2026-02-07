import '../../../../core/logging/app_logger.dart';
import '../../domain/models/assignment.dart';

abstract class AssignmentStore {
  Future<List<Assignment>> getAssignments({String? filter});
  Future<Assignment> addAssignment(Assignment assignment);
  Future<void> toggleComplete(String id);
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
    return List.from(_items);
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
}
