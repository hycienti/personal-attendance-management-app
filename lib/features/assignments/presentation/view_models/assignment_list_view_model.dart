import 'package:flutter/foundation.dart';

import '../../../../core/utils/ui_state.dart';
import '../../domain/models/assignment.dart';
import '../../data/repositories/assignment_repository.dart';

class AssignmentListViewModel extends ChangeNotifier {
  AssignmentListViewModel({AssignmentRepository? repository})
      : _repository = repository ?? MockAssignmentRepository();

  final AssignmentRepository _repository;

  UiState<List<Assignment>> _state = const UiLoading();
  String _filter = 'all';

  UiState<List<Assignment>> get state => _state;
  String get filter => _filter;

  int get pendingCount => _state.dataOrNull?.where((e) => !e.isCompleted).length ?? 0;
  int get completedCount => _state.dataOrNull?.where((e) => e.isCompleted).length ?? 0;

  void setFilter(String value) {
    _filter = value;
    load();
  }

  Future<void> load() async {
    _state = const UiLoading();
    notifyListeners();
    try {
      final list = await _repository.getAssignments(
        filter: _filter == 'all' ? null : _filter,
      );
      _state = list.isEmpty ? const UiEmpty() : UiSuccess(list);
    } catch (e) {
      _state = UiError(e.toString());
    }
    notifyListeners();
  }

  Future<void> toggleComplete(String id) async {
    await _repository.toggleComplete(id);
    load();
  }
}
