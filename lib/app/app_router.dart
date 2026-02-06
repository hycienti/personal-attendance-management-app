import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/constants/route_constants.dart';
import '../features/attendance/presentation/pages/attendance_history_page.dart';
import '../features/auth/presentation/pages/create_account_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/assignments/presentation/pages/assignment_list_page.dart';
import '../features/assignments/presentation/pages/new_assignment_page.dart';
import '../features/assignments/presentation/view_models/assignment_list_view_model.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/dashboard/presentation/view_models/dashboard_view_model.dart';
import '../features/schedule/presentation/pages/schedule_page.dart';
import '../features/schedule/presentation/pages/new_session_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import 'app_shell.dart';

/// Central router configuration. Auth routes are outside shell; rest use shell with bottom nav.
final GlobalKey<NavigatorState> _rootNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: RouteConstants.dashboard,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteConstants.createAccount,
        builder: (context, state) => const CreateAccountPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavKey,
        builder: (context, state, child) => AppShell(
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: RouteConstants.dashboard,
            pageBuilder: (_, state) => NoTransitionPage(
              child: ChangeNotifierProvider(
                create: (_) => DashboardViewModel()..load(),
                child: const DashboardPage(),
              ),
            ),
          ),
          GoRoute(
            path: RouteConstants.assignments,
            pageBuilder: (_, state) => NoTransitionPage(
              child: ChangeNotifierProvider(
                create: (_) => AssignmentListViewModel()..load(),
                child: const AssignmentListPage(),
              ),
            ),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootNavKey,
                builder: (context, state) => const NewAssignmentPage(),
              ),
            ],
          ),
          GoRoute(
            path: RouteConstants.schedule,
            pageBuilder: (_, state) => const NoTransitionPage(
              child: SchedulePage(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootNavKey,
                builder: (context, state) => const NewSessionPage(),
              ),
            ],
          ),
          GoRoute(
            path: RouteConstants.attendanceHistory,
            pageBuilder: (_, state) => const NoTransitionPage(
              child: AttendanceHistoryPage(),
            ),
          ),
          GoRoute(
            path: RouteConstants.profile,
            pageBuilder: (_, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),
    ],
  );
}
