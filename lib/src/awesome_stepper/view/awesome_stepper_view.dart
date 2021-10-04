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

class _AwesomeStepperState extends State<AwesomeStepper>
    with TickerProviderStateMixin {
  late final AwesomeStepperViewModel _viewModel;
  late final Animation<Offset> _offsetAnimation;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _viewModel = AwesomeStepperViewModel();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.5),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    ));

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      height: context.customHeight(10),
      color: Colors.grey,
      child: Row(
        children: [
          Container(
            height: context.customHeight(10),
            width: context.customHeight(10),
            padding: 10.paddingAll,
            child: Observer(builder: (_) {
              return Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(value: _controller.value),
                  Center(
                    child: Text(
                        '${widget.steps.length} / ${_viewModel.currentStep + 1} '),
                  )
                ],
              );
            }),
          ),
          Expanded(child: Observer(builder: (_) {
            return SlideTransition(
                position: _offsetAnimation,
                child: Center(
                    child: Text(widget.steps[_viewModel.currentStep].label +
                        '${_controller.value}')));
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
            height: context.customHeight(9),
            color: Colors.red,
          ).onTap(() => tap(false)),
        ),
        10.wSized,
        Expanded(
          child: Container(
            height: context.customHeight(9),
            color: Colors.green,
          ).onTap(() => tap(true)),
        ),
      ],
    );
  }

  tap(bool isIncrement) {
    _controller.forward().whenComplete(() {
      isIncrement ? _viewModel.incrementStep() : _viewModel.decrementStep();
      _controller.reverse();
    });
  }
}
