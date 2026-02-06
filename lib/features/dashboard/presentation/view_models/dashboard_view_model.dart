import 'package:flutter/foundation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/utils/ui_state.dart';
import '../../domain/models/dashboard_models.dart';
import '../../data/repositories/dashboard_repository.dart';

/// ViewModel for dashboard. Manages loading, success, empty, error states.
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({DashboardRepository? repository})
      : _repository = repository ?? MockDashboardRepository();

  final DashboardRepository _repository;

  UiState<DashboardStats> _statsState = const UiLoading();
  UiState<List<TodaySession>> _sessionsState = const UiLoading();
  UiState<List<UpcomingAssignment>> _assignmentsState = const UiLoading();

  UiState<DashboardStats> get statsState => _statsState;
  UiState<List<TodaySession>> get sessionsState => _sessionsState;
  UiState<List<UpcomingAssignment>> get assignmentsState => _assignmentsState;

  Future<void> load() async {
    _statsState = const UiLoading();
    _sessionsState = const UiLoading();
    _assignmentsState = const UiLoading();
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getStats(),
        _repository.getTodaySessions(),
        _repository.getUpcomingAssignments(),
      ]);
      _statsState = UiSuccess(results[0] as DashboardStats);
      final sessions = results[1] as List<TodaySession>;
      _sessionsState = sessions.isEmpty
          ? const UiEmpty()
          : UiSuccess(sessions);
      final assignments = results[2] as List<UpcomingAssignment>;
      _assignmentsState = assignments.isEmpty
          ? const UiEmpty()
          : UiSuccess(assignments);
    } catch (e, st) {
      AppLogger.e('Dashboard load failed', e, st);
      _statsState = UiError(e.toString());
      _sessionsState = UiError(e.toString());
      _assignmentsState = UiError(e.toString());
    }
    notifyListeners();
  }
}
