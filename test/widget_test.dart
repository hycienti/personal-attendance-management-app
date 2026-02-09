import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personal_attendance_management_app/app/app_router.dart';
import 'package:personal_attendance_management_app/features/auth/presentation/state/auth_session.dart';
import 'package:personal_attendance_management_app/main.dart';

void main() {
  testWidgets('App loads and shows dashboard or login', (WidgetTester tester) async {
    final authSession = AuthSession();
    final appRouter = createAppRouter(authSession);
    await tester.pumpWidget(AluApp(
      authSession: authSession,
      appRouter: appRouter,
    ));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
