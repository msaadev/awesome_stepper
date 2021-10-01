import 'package:awesome_stepper/awesome_stepper.dart';
import 'package:awesome_stepper/src/awesome_stepper/view_model/awesome_stepper_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:lib_msaadev/lib_msaadev.dart';

class AwesomeStepper extends StatefulWidget {
  final List<AwesomeStepperItem> steps;
  const AwesomeStepper({Key? key, required this.steps}) : super(key: key);

  @override
  State<AwesomeStepper> createState() => _AwesomeStepperState();
}

class _AwesomeStepperState extends State<AwesomeStepper> {
  late final AwesomeStepperViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AwesomeStepperViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildTop(),
        Expanded(child: buildCenter()),
        buildBottom(),
      ],
    );
  }

  Container buildTop() {
    return Container(
      height: context.customHeight(8),
      color: Colors.grey,
      child: Row(
        children: [
          Expanded(
              child: Center(
            child: Container(
              height: context.customHeight(8),
              width: context.customHeight(8),
              padding: 10.paddingAll,
              child: Observer(builder: (_) {
                return Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                        value:
                            (_viewModel.currentStep + 1) / widget.steps.length),
                    Center(
                      child: Text(
                          '${widget.steps.length} / ${_viewModel.currentStep + 1} '),
                    )
                  ],
                );
              }),
            ),
          )),
          Expanded(
              flex: 2,
              child: Observer(builder: (_) {
                return Text(widget.steps[_viewModel.currentStep].label);
              })),
        ],
      ),
    );
  }

  Widget buildCenter() => Observer(builder: (_) {
        return widget.steps[_viewModel.currentStep].content;
      });

  Widget buildBottom() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: context.customHeight(8),
            color: Colors.red,
          ).onTap(() => _viewModel.decrementStep()),
        ),
        10.wSized,
        Expanded(
          child: Container(
            height: context.customHeight(8),
            color: Colors.green,
          ).onTap(() => _viewModel.incrementStep()),
        ),
      ],
    );
  }
}
