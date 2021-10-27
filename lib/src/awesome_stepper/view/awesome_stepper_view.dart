import 'package:awesome_stepper/awesome_stepper.dart';
import 'package:awesome_stepper/src/awesome_stepper/view_model/awesome_stepper_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AwesomeStepper extends StatefulWidget {

  /// required to build steps
  final List<AwesomeStepperItem> steps;

  /// Returns active step
  final Function(int page)? onStepChanged;

  /// set the header color
  final Color? headerColor;

  /// set the progress indicator color
  final Color? progressColor;

  /// sets headers text style
  final TextStyle? headerStyle;

   /// sets progresses text style
   final TextStyle? progressStyle;

    /// sets headers height 
  final double? headerHeight;

    /// sets headers bottom controllers height 
  final double? controllerHeight;

  /// sets headers animation duration 
  final Duration? headerAnimationDuration;

  /// sets progress bar animation duration
  final Duration? progressBarAnimationDuration;

  /// sets bottom controller
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
    final double height = widget.headerHeight ?? 70;

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
    final double height = widget.controllerHeight ?? 70;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => tap(false),
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.red,
              ),
              height: height,
              alignment: Alignment.center,
              child: Text(
                'Back',
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(color: Colors.white),
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
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.green,
              ),
              height: height,
              alignment: Alignment.center,
              child: Text(
                'Next',
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(color: Colors.white),
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
