import 'package:awesome_stepper/awesome_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget stepper, {
    ThemeData? theme,
    String? restorationScopeId,
  }) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        restorationScopeId: restorationScopeId,
        home: Scaffold(body: stepper),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  List<AwesomeStepperItem> steps({
    bool optional = false,
    bool Function()? check,
  }) => [
    AwesomeStepperItem(
      label: 'One',
      content: const Text('Page 1'),
      optional: optional,
      canContinue: check,
    ),
    const AwesomeStepperItem(label: 'Two', content: Text('Page 2')),
    const AwesomeStepperItem(label: 'Three', content: Text('Page 3')),
  ];

  testWidgets('self-sized pages start at the top', (tester) async {
    await pump(
      tester,
      const AwesomeStepper(
        steps: [
          AwesomeStepperItem(
            label: 'One',
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text('Top')],
            ),
          ),
        ],
      ),
    );
    expect(tester.getTopLeft(find.text('Top')).dy, lessThan(120));
  });

  testWidgets('Skip passes an optional step without its check', (tester) async {
    await pump(
      tester,
      AwesomeStepper(steps: steps(optional: true, check: () => false)),
    );
    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Page 2'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
  });

  testWidgets('allowHeaderJump: false blocks forward taps only', (
    tester,
  ) async {
    await pump(
      tester,
      AwesomeStepper(
        headerType: AwesomeStepperHeader.numbered,
        allowHeaderJump: false,
        steps: steps(),
      ),
    );
    await tester.tap(find.text('Three'));
    await tester.pumpAndSettle();
    expect(find.text('Page 1'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    expect(find.text('Page 1'), findsOneWidget);
  });

  testWidgets('Enter goes to the next step', (tester) async {
    await pump(tester, AwesomeStepper(steps: steps()));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    Focus.of(tester.element(find.text('Page 1'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Page 2'), findsOneWidget);
  });

  testWidgets('vertical layout lists every step and opens the active one', (
    tester,
  ) async {
    await pump(
      tester,
      AwesomeStepper(
        layout: AwesomeStepperLayout.vertical,
        lineStyle: AwesomeStepperLineStyle.dashed,
        steps: steps(),
      ),
    );
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Three'), findsOneWidget);
    expect(find.text('Page 1'), findsOneWidget);
    expect(find.text('Page 2'), findsNothing);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Page 1'), findsNothing);
    expect(find.text('Page 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completedBuilder replaces the page; back() returns', (
    tester,
  ) async {
    var completed = 0;
    final controller = AwesomeStepperController();
    addTearDown(controller.dispose);
    await pump(
      tester,
      AwesomeStepper(
        controller: controller,
        steps: steps().sublist(0, 2),
        onCompleted: () => completed++,
        completedBuilder: (_) => const Text('All done'),
      ),
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.text('All done'), findsOneWidget);
    expect(find.text('Finish'), findsNothing);
    expect(completed, 1);

    expect(await controller.back(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Page 2'), findsOneWidget);
    expect(find.text('Finish'), findsOneWidget);
  });

  for (final transition in AwesomeStepperTransition.values) {
    testWidgets('${transition.name} transition switches pages', (tester) async {
      await pump(
        tester,
        AwesomeStepper(transition: transition, steps: steps()),
      );
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Page 2'), findsOneWidget);
      expect(find.text('Page 1'), findsNothing);
    });
  }

  testWidgets('restores the active step', (tester) async {
    await pump(
      tester,
      AwesomeStepper(restorationId: 'checkout', steps: steps()),
      restorationScopeId: 'app',
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Page 2'), findsOneWidget);

    await tester.restartAndRestore();
    await tester.pumpAndSettle();
    expect(find.text('Page 2'), findsOneWidget);
  });

  testWidgets('theme extension sets the accent', (tester) async {
    const teal = Color(0xFF009688);
    await pump(
      tester,
      AwesomeStepper(steps: steps()),
      theme: ThemeData(
        extensions: const [AwesomeStepperTheme(accentColor: teal)],
      ),
    );
    final circle = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(circle.color, teal);
  });

  group('AwesomeStepIndicator', () {
    testWidgets('shows the step and animates on change', (tester) async {
      var step = 0;
      late StateSetter setStep;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setStep = setState;
            return AwesomeStepIndicator(
              currentStep: step,
              labels: const ['Cart', 'Address', 'Payment'],
            );
          },
        ),
      );
      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);

      setStep(() => step = 2);
      await tester.pumpAndSettle();
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('3 / 3'), findsOneWidget);
    });

    testWidgets('numbered steps report taps', (tester) async {
      int? tapped;
      await pump(
        tester,
        AwesomeStepIndicator(
          type: AwesomeStepperHeader.numbered,
          totalSteps: 4,
          currentStep: 1,
          lineStyle: AwesomeStepperLineStyle.dotted,
          onStepTapped: (i) => tapped = i,
        ),
      );
      await tester.tap(find.text('4'));
      expect(tapped, 3);
    });
  });
}
