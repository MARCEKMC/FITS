import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fits/modules/efficiency/widgets/day_strip.dart';

void main() {
  testWidgets('DayStrip widget builds correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DayStrip(
            selectedDate: DateTime.now(),
            onDateSelected: (date) {},
          ),
        ),
      ),
    );

    expect(find.byType(DayStrip), findsOneWidget);
  });
}
