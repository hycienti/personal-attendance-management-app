import '../../../../core/database/app_database.dart';
import '../../domain/models/assignment.dart';
import 'assignment_store.dart';

class SqliteAssignmentStore implements AssignmentStore {
  SqliteAssignmentStore({AppDatabase? db}) : _db = db ?? AppDatabase.instance!;

  final AppDatabase _db;

  static Assignment _rowToAssignment(Map<String, dynamic> row) {
    final priorityStr = row['priority'] as String? ?? 'medium';
    AssignmentPriority priority;
    switch (priorityStr) {
      case 'high':
        priority = AssignmentPriority.high;
        break;
      case 'low':
        priority = AssignmentPriority.low;
        break;
      default:
        priority = AssignmentPriority.medium;
    }
    final dueDateStr = row['due_date'] as String?;
    DateTime? dueDate;
    if (dueDateStr != null && dueDateStr.isNotEmpty) {
      dueDate = DateTime.tryParse(dueDateStr);
    }
    return Assignment(
      id: row['id'] as String,
      title: row['title'] as String,
      courseName: row['course_name'] as String?,
      dueDate: dueDate,
      dueTime: row['due_time'] as String?,
      priority: priority,
      isCompleted: (row['is_completed'] as int? ?? 0) == 1,
      notes: row['notes'] as String?,
    );
  }

  @override
  Future<List<Assignment>> getAssignments({String? filter}) async {
    final rows = await _db.getAssignments(filter: filter);
    return rows.map(_rowToAssignment).toList();
  }

  @override
  Future<Assignment> addAssignment(Assignment assignment) async {
    final priorityStr = assignment.priority.name;
    final row = await _db.insertAssignment({
      'title': assignment.title,
      'course_name': assignment.courseName,
      'due_date': assignment.dueDate?.toIso8601String().split('T').first,
      'due_time': assignment.dueTime,
      'priority': priorityStr,
      'is_completed': assignment.isCompleted ? 1 : 0,
      'notes': assignment.notes,
    });
    return _rowToAssignment(Map<String, dynamic>.from(row));
  }

  @override
  Future<void> toggleComplete(String id) async {
    await _db.toggleAssignmentComplete(id);
  }
}
