import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personal_attendance_management_app/main.dart';

void main() {
  testWidgets('App loads and shows dashboard or login', (WidgetTester tester) async {
    await tester.pumpWidget(const AluApp());
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
