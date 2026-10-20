import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:awesome_stepper/awesome_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    List<AwesomeStepperItem>? steps,
    AwesomeStepperController? controller,
    ValueChanged<int>? onStepChanged,
    VoidCallback? onCompleted,
    AwesomeStepperHeader headerType = AwesomeStepperHeader.circle,
    Size size = const Size(400, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AwesomeStepper(
            controller: controller,
            onStepChanged: onStepChanged,
            onCompleted: onCompleted,
            headerType: headerType,
            steps:
                steps ??
                const [
                  AwesomeStepperItem(label: 'One', content: Text('Page 1')),
                  AwesomeStepperItem(label: 'Two', content: Text('Page 2')),
                ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  testWidgets('next and back move between steps', (tester) async {
    final changes = <int>[];
    await pump(tester, onStepChanged: changes.add);
    expect(find.text('Page 1'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Page 2'), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Page 1'), findsOneWidget);
    expect(changes, [1, 0]);
  });

  testWidgets('last step shows Finish and calls onCompleted', (tester) async {
    var completed = 0;
    await pump(tester, onCompleted: () => completed++);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(completed, 1);
    expect(find.text('Page 2'), findsOneWidget);
  });

  testWidgets('canContinue false keeps the step and marks an error', (
    tester,
  ) async {
    var allowed = false;
    await pump(
      tester,
      headerType: AwesomeStepperHeader.numbered,
      steps: [
        AwesomeStepperItem(
          label: 'Form',
          content: const Text('Page 1'),
          canContinue: () async => allowed,
        ),
        const AwesomeStepperItem(label: 'Done', content: Text('Page 2')),
      ],
    );

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Page 1'), findsOneWidget);
    expect(find.byIcon(Icons.priority_high_rounded), findsOneWidget);

    allowed = true;
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Page 2'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('disabled steps are skipped', (tester) async {
    await pump(
      tester,
      steps: const [
        AwesomeStepperItem(label: 'One', content: Text('Page 1')),
        AwesomeStepperItem(
          label: 'Two',
          content: Text('Page 2'),
          enabled: false,
        ),
        AwesomeStepperItem(label: 'Three', content: Text('Page 3')),
      ],
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Page 3'), findsOneWidget);
  });

  testWidgets('controller drives the stepper', (tester) async {
    final controller = AwesomeStepperController();
    addTearDown(controller.dispose);
    await pump(tester, controller: controller);
    expect(controller.stepCount, 2);

    expect(await controller.next(), isTrue);
    await tester.pumpAndSettle();
    expect(controller.currentStep, 1);
    expect(find.text('Page 2'), findsOneWidget);

    expect(await controller.jumpTo(0), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Page 1'), findsOneWidget);
    expect(await controller.back(), isFalse);
  });

  testWidgets('every header type renders', (tester) async {
    for (final type in AwesomeStepperHeader.values) {
      await pump(tester, headerType: type);
      expect(find.text('Page 1'), findsOneWidget, reason: type.name);
    }
  });

  testWidgets('wide window shows the side list', (tester) async {
    await pump(tester, size: const Size(1000, 700));
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('bar and dots stay as they are on wide windows', (tester) async {
    await pump(
      tester,
      size: const Size(1100, 760),
      headerType: AwesomeStepperHeader.bar,
    );
    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    await pump(
      tester,
      size: const Size(1100, 760),
      headerType: AwesomeStepperHeader.dots,
    );
    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(Wrap), findsOneWidget);
  });

  testWidgets('wide windows keep the page and buttons in a 720 px column', (
    tester,
  ) async {
    await pump(
      tester,
      size: const Size(1200, 800),
      headerType: AwesomeStepperHeader.dots,
    );
    final next = tester.getRect(find.text('Next'));
    final back = tester.getRect(find.text('Back'));
    expect(next.right - back.left, lessThanOrEqualTo(720));
    expect(tester.getCenter(find.text('Page 1')).dx, 600);
  });

  testWidgets('numbered header fits a narrow pane without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              const SizedBox(width: 640),
              Expanded(
                child: AwesomeStepper(
                  headerType: AwesomeStepperHeader.numbered,
                  steps: [
                    for (var i = 0; i < 3; i++)
                      AwesomeStepperItem(label: 'S$i', content: Text('P$i')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('side list splits at a vertical fold', (tester) async {
    tester.view.physicalSize = const Size(951, 669);
    tester.view.devicePixelRatio = 1;
    tester.view.displayFeatures = const [
      DisplayFeature(
        bounds: Rect.fromLTWH(455, 0, 40, 669),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureHalfOpened,
      ),
    ];
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AwesomeStepper(
            sideBySideMinWidth: 600,
            steps: [
              AwesomeStepperItem(label: 'One', content: Text('Page 1')),
              AwesomeStepperItem(label: 'Two', content: Text('Page 2')),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Page 1')).dx,
      greaterThanOrEqualTo(495),
    );
  });

  testWidgets('screen reader label names the step', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);
    expect(find.bySemanticsLabel(RegExp('^Step 1 of 2: One')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('disposing before the first progress animation is safe', (
    tester,
  ) async {
    await pump(
      tester,
      steps: const [AwesomeStepperItem(label: 'One', content: SizedBox())],
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
