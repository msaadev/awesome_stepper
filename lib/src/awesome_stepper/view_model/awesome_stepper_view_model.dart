import 'package:mobx/mobx.dart';
part 'awesome_stepper_view_model.g.dart';

class AwesomeStepperViewModel = _AwesomeStepperViewModelBase
    with _$AwesomeStepperViewModel;

abstract class _AwesomeStepperViewModelBase with Store {
  @observable
  int currentStep = 0;
  @action
  void setStep(int step) => currentStep = step;

  @action
  void incrementStep() {
    currentStep++;
  }

  @action
  void decrementStep() {
    currentStep--;
  }
}
