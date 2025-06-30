import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fits/ui/screens/efficiency/schedule_screen.dart';

void main() {
  testWidgets('ScheduleScreen builds without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: ScheduleScreen(),
    ));

    // Verify that the screen builds successfully
    expect(find.byType(ScheduleScreen), findsOneWidget);
  });
}
