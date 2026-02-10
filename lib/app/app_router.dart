import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/constants/route_constants.dart';
import '../features/assignments/data/stores/assignment_store.dart';
import '../features/attendance/data/stores/attendance_store.dart';
import '../features/attendance/presentation/pages/attendance_history_page.dart';
import '../features/auth/presentation/state/auth_session.dart';
import '../features/auth/presentation/pages/create_account_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/assignments/domain/models/assignment.dart';
import '../features/assignments/presentation/pages/assignment_list_page.dart';
import '../features/assignments/presentation/pages/new_assignment_page.dart';
import '../features/assignments/presentation/view_models/assignment_list_view_model.dart';
import '../features/dashboard/data/stores/dashboard_store.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/dashboard/presentation/view_models/dashboard_view_model.dart';
import '../features/schedule/presentation/pages/schedule_page.dart';
import '../features/schedule/presentation/pages/new_session_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import 'app_shell.dart';

/// Central router configuration. Auth routes are outside shell; rest use shell with bottom nav.
final GlobalKey<NavigatorState> _rootNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(AuthSession authSession) {
  return GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: RouteConstants.dashboard,
    debugLogDiagnostics: true,
    refreshListenable: authSession,
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = authSession.isLoggedIn;
      final isAuthRoute = state.matchedLocation == RouteConstants.login ||
          state.matchedLocation == RouteConstants.createAccount;
      if (!loggedIn && !isAuthRoute) return RouteConstants.login;
      if (loggedIn && isAuthRoute) return RouteConstants.dashboard;
      return null;
    },
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
            pageBuilder: (context, state) => NoTransitionPage(
              child: ChangeNotifierProvider(
                create: (_) => DashboardViewModel(
                  store: context.read<DashboardStore>(),
                )..load(),
                child: const DashboardPage(),
              ),
            ),
          ),
          GoRoute(
            path: RouteConstants.assignments,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ChangeNotifierProvider(
                create: (_) => AssignmentListViewModel(
                  store: context.read<AssignmentStore>(),
                )..load(),
                child: const AssignmentListPage(),
              ),
            ),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: _rootNavKey,
                builder: (context, state) => const NewAssignmentPage(),
              ),
              GoRoute(
                path: ':id/edit',
                parentNavigatorKey: _rootNavKey,
                builder: (context, state) {
                  final assignment = state.extra as Assignment?;
                  return NewAssignmentPage(editing: assignment);
                },
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
            pageBuilder: (context, state) => NoTransitionPage(
              child: AttendanceHistoryPage(
                store: context.read<AttendanceStore>(),
              ),
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
