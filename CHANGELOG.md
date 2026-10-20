## 1.0.1

* Fixed: on wide windows (tablets, desktop, open foldables) the `bar` and `dots` headers were not shown; they now sit above the page next to the side list.
* Fixed: the `numbered` header measured the screen instead of its own width, so it could overflow inside a pane.
* New logo.

## 1.0.0

* New design: Material 3 colors from the theme, dark mode, sliding pages, cross-fading title, rounded progress.
* Header styles: `circle` (classic, default), `bar`, `dots`, `numbered`.
* `canContinue` per step (sync or async) for form validation; error state on failure.
* Step states: completed, error, locked (`enabled: false` steps are skipped).
* `AwesomeStepperController`: `next()`, `back()`, `jumpTo()`, `currentStep`.
* `onCompleted`, Finish label on the last step, Back disabled on the first.
* Side-by-side layout from 840 px; follows the vertical fold on foldables.
* Accessibility: screen reader step announcements, 48 px buttons, RTL, arrow keys, swipe, haptics.
* Translatable labels: `nextLabel`, `backLabel`, `finishLabel`, `semanticsLabel`.
* Dart 3 (SDK `^3.8.0`); no dependencies besides Flutter (mobx removed).
* Fixed: crash on Next at the last step / Back at the first step; crash when disposed during the intro animation.

## 0.2.0 (not published, merged into 1.0.0)

* Dart 3 / current Flutter support (SDK `^3.8.0`).
* Removed the `mobx`, `flutter_mobx` and `mobx_codegen` dependencies; the package has no dependencies besides Flutter now.
* Fixed a crash when tapping Next on the last step or Back on the first step.
* Fixed a crash when the stepper is disposed before its first progress animation.
* `onStepChanged` is now `ValueChanged<int>`, `controlBuilder` receives `VoidCallback`s.
* `AwesomeStepperItem` is `const`.
* Added widget tests; homepage moved to monsware.com.

## 0.0.1

* First initial release

## 0.0.2

* Web Support added

## 0.0.3

* Documents Added

## 0.1.0

* Documents updated

## 0.1.2

* document text added

## 0.1.3

* project formatted
