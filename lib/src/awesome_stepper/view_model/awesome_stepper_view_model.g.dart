// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'awesome_stepper_view_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AwesomeStepperViewModel on _AwesomeStepperViewModelBase, Store {
  final _$currentStepAtom =
      Atom(name: '_AwesomeStepperViewModelBase.currentStep');

  @override
  int get currentStep {
    _$currentStepAtom.reportRead();
    return super.currentStep;
  }

  @override
  set currentStep(int value) {
    _$currentStepAtom.reportWrite(value, super.currentStep, () {
      super.currentStep = value;
    });
  }

  final _$_AwesomeStepperViewModelBaseActionController =
      ActionController(name: '_AwesomeStepperViewModelBase');

  @override
  void setStep(int step) {
    final _$actionInfo = _$_AwesomeStepperViewModelBaseActionController
        .startAction(name: '_AwesomeStepperViewModelBase.setStep');
    try {
      return super.setStep(step);
    } finally {
      _$_AwesomeStepperViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void incrementStep() {
    final _$actionInfo = _$_AwesomeStepperViewModelBaseActionController
        .startAction(name: '_AwesomeStepperViewModelBase.incrementStep');
    try {
      return super.incrementStep();
    } finally {
      _$_AwesomeStepperViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void decrementStep() {
    final _$actionInfo = _$_AwesomeStepperViewModelBaseActionController
        .startAction(name: '_AwesomeStepperViewModelBase.decrementStep');
    try {
      return super.decrementStep();
    } finally {
      _$_AwesomeStepperViewModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentStep: ${currentStep}
    ''';
  }
}
