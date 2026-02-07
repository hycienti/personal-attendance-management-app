import 'package:flutter/foundation.dart';

import '../../../../core/constants/validation_constants.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/models/assignment.dart';
import '../../data/stores/assignment_store.dart';

class NewAssignmentViewModel extends ChangeNotifier {
  NewAssignmentViewModel({AssignmentStore? store})
      : _store = store ?? MockAssignmentStore();

  final AssignmentStore _store;

  String? _titleError;
  bool _isSaving = false;
  String? _saveError;

  String? get titleError => _titleError;
  bool get isSaving => _isSaving;
  String? get saveError => _saveError;

  bool validate(String title) {
    if (title.trim().isEmpty) {
      _titleError = ValidationConstants.requiredField;
      notifyListeners();
      return false;
    }
    if (title.length > ValidationConstants.maxAssignmentTitleLength) {
      _titleError = ValidationConstants.titleTooLong;
      notifyListeners();
      return false;
    }
    _titleError = null;
    notifyListeners();
    return true;
  }

  Future<bool> save({
    required String title,
    String? courseName,
    DateTime? dueDate,
    String? dueTime,
    AssignmentPriority priority = AssignmentPriority.medium,
    String? notes,
  }) async {
    if (!validate(title)) return false;
    _isSaving = true;
    _saveError = null;
    notifyListeners();
    try {
      await _store.addAssignment(
        Assignment(
          id: '',
          title: title.trim(),
          courseName: courseName?.trim().isEmpty == true ? null : courseName?.trim(),
          dueDate: dueDate,
          dueTime: dueTime,
          priority: priority,
          notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
        ),
      );
      AppLogger.i('Assignment saved: $title');
      return true;
    } catch (e, st) {
      AppLogger.e('Save assignment failed', e, st);
      _saveError = 'Failed to save. Please try again.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
