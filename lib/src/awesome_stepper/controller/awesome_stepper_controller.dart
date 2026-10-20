part of '../view/awesome_stepper_view.dart';

/// Moves an [AwesomeStepper] from code and reports its active step.
///
/// Listen to it (it is a [ChangeNotifier]) to react to step changes.
class AwesomeStepperController extends ChangeNotifier {
  int _currentStep;
  _AwesomeStepperState? _state;

  /// Creates a controller that starts at [initialStep].
  AwesomeStepperController({int initialStep = 0}) : _currentStep = initialStep;

  /// Index of the active step.
  int get currentStep => _currentStep;

  /// Number of steps of the attached stepper, 0 when not attached.
  int get stepCount => _state?.widget.steps.length ?? 0;

  /// Goes to the next enabled step after the current step's `canContinue`
  /// check. On the last step it calls `onCompleted` instead.
  /// Returns whether it moved (or completed).
  Future<bool> next() => _state?._next() ?? Future.value(false);

  /// Goes to the previous enabled step. Returns whether it moved.
  Future<bool> back() => _state?._back() ?? Future.value(false);

  /// Goes to [step]. Going forward runs the `canContinue` check of every
  /// step on the way and stops at the first one that fails.
  Future<bool> jumpTo(int step) => _state?._jumpTo(step) ?? Future.value(false);

  void _set(int step) {
    if (_currentStep == step) return;
    _currentStep = step;
    notifyListeners();
  }
}
