import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/app_router.dart';
import 'core/database/app_database.dart';
import 'core/theme/app_theme.dart';
import 'features/assignments/data/stores/assignment_store.dart';
import 'features/assignments/data/stores/sqlite_assignment_store.dart';
import 'features/attendance/data/stores/attendance_store.dart';
import 'features/attendance/data/stores/sqlite_attendance_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await AppDatabase.init();
  } catch (_) {}

  runApp(const AluApp());
}

class AluApp extends StatelessWidget {
  const AluApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
      ],
      child: MaterialApp.router(
        title: 'ALU Assistant',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: createAppRouter(),
      ),
    );
  }
}
