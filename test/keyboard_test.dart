import 'package:awesome_stepper/awesome_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget field) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AwesomeStepper(
          steps: [
            AwesomeStepperItem(label: 'One', content: field),
            const AwesomeStepperItem(label: 'Two', content: Text('Page 2')),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _typeAndEnter(WidgetTester tester) async {
  await tester.tap(find.byType(TextField));
  await tester.enterText(find.byType(TextField), 'line');
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Enter in a multi-line field stays on the step', (tester) async {
    await _pump(tester, const TextField(maxLines: 4));
    await _typeAndEnter(tester);
    expect(find.text('Page 2'), findsNothing);
    expect(find.text('line', findRichText: true), findsOneWidget);
  });

  testWidgets('Enter in an unbounded multi-line field stays on the step', (
    tester,
  ) async {
    await _pump(tester, const TextField(maxLines: null));
    await _typeAndEnter(tester);
    expect(find.text('Page 2'), findsNothing);
  });

  testWidgets('Enter in a single-line field goes to the next step', (
    tester,
  ) async {
    await _pump(tester, const TextField());
    await _typeAndEnter(tester);
    expect(find.text('Page 2'), findsOneWidget);
  });
}
