import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:module3_lesson2_activity/main.dart';

void main() {
  Future<void> addTask(WidgetTester tester, String title) async {
    await tester.enterText(find.byType(TextField), title);
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pump();
  }

  testWidgets('starts with no tasks', (tester) async {
    await tester.pumpWidget(const TaskApp());

    expect(find.text('No tasks yet. Add one above.'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('added tasks are displayed while the app is running',
      (tester) async {
    await tester.pumpWidget(const TaskApp());

    await addTask(tester, 'Complete laboratory activity');
    await addTask(tester, 'Review lesson materials');

    expect(find.text('Complete laboratory activity'), findsOneWidget);
    expect(find.text('Review lesson materials'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.text('Tasks in memory: 2'), findsOneWidget);
  });

  testWidgets('empty and whitespace-only titles are not added', (tester) async {
    await tester.pumpWidget(const TaskApp());

    await addTask(tester, '');
    await addTask(tester, '     ');

    expect(find.byType(ListTile), findsNothing);
    expect(find.text('Tasks in memory: 0'), findsOneWidget);
  });

  testWidgets('tasks are lost when the app is relaunched', (tester) async {
    await tester.pumpWidget(const TaskApp());
    await addTask(tester, 'Submit assignment');
    expect(find.text('Submit assignment'), findsOneWidget);

    // Simulate terminating the process: tear the whole widget tree down...
    await tester.pumpWidget(const SizedBox.shrink());
    // ...and launching the app again from scratch.
    await tester.pumpWidget(const TaskApp());

    expect(find.text('Submit assignment'), findsNothing);
    expect(find.text('No tasks yet. Add one above.'), findsOneWidget);
  });
}
