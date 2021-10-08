import 'package:awesome_stepper/awesome_stepper.dart';
import 'package:awesome_stepper/src/awesome_stepper/view_model/awesome_stepper_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kartal/kartal.dart';

class AwesomeStepper extends StatefulWidget {
  final List<AwesomeStepperItem> steps;
  final Function(int page)? onStepChanged;
  const AwesomeStepper({Key? key, required this.steps, this.onStepChanged})
      : super(key: key);

  @override
  State<AwesomeStepper> createState() => _AwesomeStepperState();
}

class _AwesomeStepperState extends State<AwesomeStepper>
    with TickerProviderStateMixin {
  late final AwesomeStepperViewModel _viewModel;
  late final Animation<double> textAnimation;
  late final AnimationController _controller, _circleValue;
  late final double ratio;

  @override
  void initState() {
    super.initState();

    _viewModel = AwesomeStepperViewModel();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _circleValue = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    textAnimation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    ));
    _circleValue.addListener(() {
      setState(() {});
    });

    ratio = 1 / widget.steps.length;

    Future.delayed(Duration(milliseconds: 500))
        .whenComplete(() => _circleValue.animateTo(ratio));
  }

  @override
  void dispose() {
    _controller.dispose();
    _circleValue.dispose();
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
      height: context.dynamicHeight(.1),
      
      color: Colors.grey,
      child: Row(
        children: [
          Container(
            height: context.dynamicHeight(.1),
            width: context.dynamicHeight(.1),
            padding: EdgeInsets.all(10),
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
            return FadeTransition(
                opacity: textAnimation,
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
          child: InkWell(
            onTap:() => tap(false),
            child: Container(
              height: context.dynamicHeight(.1),
              color: Colors.red,
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: InkWell(
            onTap:() => tap(true),
            child: Container(
              height: context.dynamicHeight(.1),
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  tap(bool isIncrement) {
    isIncrement
        ? _circleValue.animateTo(_circleValue.value + ratio)
        : _circleValue.animateTo(_circleValue.value - ratio);
    _controller.forward().whenComplete(() {
      isIncrement ? _viewModel.incrementStep() : _viewModel.decrementStep();

      if (widget.onStepChanged != null)
        widget.onStepChanged!(_viewModel.currentStep + 1);

      _controller.reverse();
    });
  }
}
