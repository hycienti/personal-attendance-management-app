import 'package:flutter/foundation.dart';

import '../../../../core/utils/ui_state.dart';
import '../../domain/models/assignment.dart';
import '../../data/stores/assignment_store.dart';

class AssignmentListViewModel extends ChangeNotifier {
  AssignmentListViewModel({AssignmentStore? store})
      : _store = store ?? MockAssignmentStore();

  final AssignmentStore _store;

  UiState<List<Assignment>> _state = const UiLoading();
  String _filter = 'all';
  int _pendingCount = 0;
  int _completedCount = 0;

  UiState<List<Assignment>> get state => _state;
  String get filter => _filter;
  int get pendingCount => _pendingCount;
  int get completedCount => _completedCount;

  /// Weekly completion rate: completed / total * 100 (0-100).
  int get weeklyCompletionRate {
    final total = _pendingCount + _completedCount;
    if (total == 0) return 0;
    return ((_completedCount / total) * 100).round();
  }

  void setFilter(String value) {
    _filter = value;
    load();
  }

  Future<void> load() async {
    _state = const UiLoading();
    notifyListeners();
    try {
      final results = await Future.wait([
        _store.getAssignments(filter: _filter == 'all' ? null : _filter),
        _store.getAssignments(filter: null),
      ]);
      final list = results[0];
      final allList = results[1];
      _pendingCount = allList.where((e) => !e.isCompleted).length;
      _completedCount = allList.where((e) => e.isCompleted).length;
      _state = list.isEmpty ? const UiEmpty() : UiSuccess(list);
    } catch (e) {
      _state = UiError(e.toString());
    }
    notifyListeners();
  }

  Future<void> toggleComplete(String id) async {
    await _store.toggleComplete(id);
    load();
  }

  Future<void> deleteAssignment(String id) async {
    await _store.deleteAssignment(id);
    load();
  }
}
