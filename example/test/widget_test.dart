import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pull_to_reveal/pull_to_reveal.dart';

Widget getTestApp({int itemCount = 0, required bool revealWhenEmpty}) =>
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: PullToRevealTopItemList(
            itemBuilder: (context, num) => Container(
              child: Text('$num'),
              key: Key('$num'),
            ),
            itemCount: itemCount,
            revealableBuilder: (context, opener, closer, constraints) => Text(
              'Peek-a-boo!',
              key: Key('revealable-text'),
            ),
            revealableHeight: 50,
            revealWhenEmpty: revealWhenEmpty,
          ),
        ),
      ),
    );

void main() {
  testWidgets('Tests the revealable responses to `revealWhenEmpty=true`',
      (WidgetTester tester) async {
    await tester.pumpWidget(getTestApp(revealWhenEmpty: true));
    expect(find.byKey(Key('revealable-text')), findsOneWidget);
  });

  testWidgets('Tests the revealable responses to `revealWhenEmpty=false`',
      (WidgetTester tester) async {
    await tester.pumpWidget(getTestApp(revealWhenEmpty: false));
    expect(find.byKey(Key('revealable-text')), findsNothing);
  });

  testWidgets(
    'Tests that dragging the list down reveals our item',
    (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(getTestApp(itemCount: 1, revealWhenEmpty: false));

      expect(find.byKey(Key('revealable-text')), findsNothing);

      await tester.drag(find.byKey(Key('0')), Offset(0, 100.0));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('revealable-text')), findsOneWidget);
    },
  );
}
