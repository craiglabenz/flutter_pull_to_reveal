// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Tests the revealable responses to `revealWhenEmpty=true`', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.byKey(Key('scrollable-row')), findsOneWidget);
  });

  testWidgets('Tests the revealable responses to `revealWhenEmpty=false`', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(revealWhenEmpty: false));
    expect(find.byKey(Key('scrollable-row')), findsNothing);
  });

  testWidgets('Tests that dragging the list down reveals our item', (WidgetTester tester) async {
// Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(revealWhenEmpty: false));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.byKey(Key('scrollable-row')), findsNothing);

    await tester.drag(find.byKey(Key('0')), Offset(0, 100.0));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('scrollable-row')), findsOneWidget);
  });
}
