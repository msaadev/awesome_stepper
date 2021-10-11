import 'package:awesome_stepper/awesome_stepper.dart';
import 'package:awesome_stepper/src/awesome_stepper/view_model/awesome_stepper_view_model.dart';
import 'package:awesome_stepper/src/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AwesomeStepper extends StatefulWidget {
  final List<AwesomeStepperItem> steps;
  final Function(int page)? onStepChanged;
  final Color? headerColor, progressColor;
  final TextStyle? headerStyle, progressStyle;
  final double? headerHeight, controllerHeight;
  final Duration? headerAnimationDuration, progressBarAnimationDuration;
  final Widget Function(Function() onNextTapped, Function() onBackTapped)?
      controlBuilder;

  const AwesomeStepper(
      {Key? key,
      required this.steps,
      this.onStepChanged,
      this.headerColor,
      this.headerStyle,
      this.progressStyle,
      this.headerAnimationDuration,
      this.progressBarAnimationDuration,
      this.controlBuilder,
      this.progressColor,
      this.headerHeight,
      this.controllerHeight})
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
      duration:
          widget.headerAnimationDuration ?? const Duration(milliseconds: 250),
      vsync: this,
    );
    _circleValue = AnimationController(
      duration: widget.progressBarAnimationDuration ?? Duration(seconds: 1),
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
    final double height = widget.headerHeight ?? context.dynamicHeight(0.1);

    return Container(
      height: height,
      color: widget.headerColor ?? Colors.white,
      child: Row(
        children: [
          Container(
            height: height,
            width: height,
            padding: EdgeInsets.all(10),
            child: Observer(builder: (_) {
              return Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _circleValue.value,
                    color: widget.progressColor,
                  ),
                  Center(
                    child: Text(
                      ' ${_viewModel.currentStep + 1} / ${widget.steps.length}  ',
                      style: widget.progressStyle,
                    ),
                  )
                ],
              );
            }),
          ),
          Expanded(child: Observer(builder: (_) {
            return FadeTransition(
                opacity: textAnimation,
                child: Center(
                    child: Text(
                  widget.steps[_viewModel.currentStep].label,
                  style: widget.headerStyle,
                )));
          })),
        ],
      ),
    );
  }

  Widget buildCenter() => Observer(builder: (_) {
        return widget.steps[_viewModel.currentStep].content;
      });

  Widget buildBottom() {
    if (widget.controlBuilder != null) {
      return widget.controlBuilder!(() {
        tap(true);
      }, () {
        tap(false);
      });
    } else {
      return defaultController();
    }
  }

  Widget defaultController() {
    final double height = widget.controllerHeight ?? context.dynamicHeight(0.1);
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => tap(false),
            child: Container(
              margin: context.paddingLow,
              decoration: BoxDecoration(
                borderRadius: context.lowBorderRadius,
                color: Colors.red,
              ),
              height: height,
              alignment: Alignment.center,
              child: Text(
                'Back',
                style:
                    context.textTheme.headline6!.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: InkWell(
            onTap: () => tap(true),
            child: Container(
              margin: context.paddingLow,
              decoration: BoxDecoration(
                borderRadius: context.lowBorderRadius,
                color: Colors.green,
              ),
              height: height,
              alignment: Alignment.center,
              child: Text(
                'Next',
                style:
                    context.textTheme.headline6!.copyWith(color: Colors.white),
              ),
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
        widget.onStepChanged!(_viewModel.currentStep);

      _controller.reverse();
    });
  }
}
