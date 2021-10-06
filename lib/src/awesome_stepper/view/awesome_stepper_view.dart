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
  late final AnimationController _controller, _circleValue;
  late final double ratio;

  @override
  void initState() {
    super.initState();
    _viewModel = AwesomeStepperViewModel();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _circleValue = AnimationController(
      duration: 1.secondDuration,
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.5),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    ));
    _circleValue.addListener(() {
      setState(() {});
    });

    ratio = 1 / widget.steps.length;

    Future.delayed(500.millisecondsDuration)
        .whenComplete(() => _circleValue.animateTo(ratio));
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
                  CircularProgressIndicator(value: _circleValue.value),
                  Center(
                    child: Text(
                        '${_viewModel.currentStep + 1} / ${widget.steps.length}  '),
                  )
                ],
              );
            }),
          ),
          Expanded(child: Observer(builder: (_) {
            return SlideTransition(
                position: _offsetAnimation,
                child: Center(
                    child: Text(widget.steps[_viewModel.currentStep].label)));
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
   isIncrement ? _circleValue.animateTo(_circleValue.value + ratio) : _circleValue.animateTo(_circleValue.value - ratio);
    _controller.forward().whenComplete(() {
      isIncrement ? _viewModel.incrementStep() : _viewModel.decrementStep();
      _controller.reverse();
    });
  }
}
