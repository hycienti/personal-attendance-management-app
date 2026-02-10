import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app/app_router.dart';
import 'core/database/app_database.dart';
import 'core/logging/app_logger.dart';
import 'core/theme/app_theme.dart';
import 'features/assignments/data/stores/assignment_store.dart';
import 'features/assignments/data/stores/sqlite_assignment_store.dart';
import 'features/attendance/data/stores/attendance_store.dart';
import 'features/attendance/data/stores/sqlite_attendance_store.dart';
import 'features/auth/presentation/state/auth_session.dart';
import 'features/dashboard/data/stores/dashboard_store.dart';
import 'features/dashboard/data/stores/dashboard_store_impl.dart';
import 'features/schedule/data/stores/schedule_store.dart';
import 'features/schedule/data/stores/sqlite_schedule_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await AppDatabase.init();
  } catch (e, st) {
    AppLogger.e('AppDatabase.init failed', e, st);
  }

  final authSession = AuthSession();
  await authSession.loadSession();

  runApp(AluApp(
    authSession: authSession,
    appRouter: createAppRouter(authSession),
  ));
}

class AluApp extends StatelessWidget {
  const AluApp({
    super.key,
    required this.authSession,
    required this.appRouter,
  });

  final AuthSession authSession;
  final GoRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthSession>.value(value: authSession),
        Provider<AssignmentStore>(
          create: (_) => AppDatabase.instance != null
              ? SqliteAssignmentStore() as AssignmentStore
              : MockAssignmentStore(),
        ),
        Provider<AttendanceStore>(
          create: (_) => AppDatabase.instance != null
              ? SqliteAttendanceStore() as AttendanceStore
              : MockAttendanceStore(),
        ),
        Provider<ScheduleStore>(
          create: (_) => AppDatabase.instance != null
              ? SqliteScheduleStore() as ScheduleStore
              : MockScheduleStore(),
        ),
        Provider<DashboardStore>(
          create: (c) {
            final DashboardStore store = AppDatabase.instance != null
                ? DashboardStoreImpl(
                    scheduleStore: c.read<ScheduleStore>(),
                    assignmentStore: c.read<AssignmentStore>(),
                  )
                : MockDashboardStore();
            return store;
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'ALU Assistant',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        routerConfig: appRouter,
      ),
    );
  }
}
