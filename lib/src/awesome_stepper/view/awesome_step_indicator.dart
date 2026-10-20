import 'package:awesome_stepper/src/awesome_stepper/model/awesome_stepper_item.dart';
import 'package:awesome_stepper/src/awesome_stepper/model/awesome_stepper_theme.dart';
import 'package:awesome_stepper/src/awesome_stepper/view/stepper_headers.dart';
import 'package:flutter/material.dart';

/// Just the step progress indicator, without pages or buttons: drop it into
/// any layout and drive it with [currentStep].
///
/// ```dart
/// AwesomeStepIndicator(
///   type: AwesomeStepperHeader.bar,
///   currentStep: 1,
///   labels: const ['Cart', 'Address', 'Payment'],
/// )
/// ```
class AwesomeStepIndicator extends StatefulWidget {
  /// Index of the active step.
  final int currentStep;

  /// Step titles; their count is the number of steps.
  final List<String>? labels;

  /// Number of steps when there are no [labels].
  final int? totalSteps;

  /// Indicator style.
  final AwesomeStepperHeader type;

  /// Progress and active step color. Defaults to the theme.
  final Color? color;

  /// Background. Defaults to transparent.
  final Color? background;

  /// Style of the lines between numbered steps.
  final AwesomeStepperLineStyle lineStyle;

  /// Called when a numbered step is tapped.
  final ValueChanged<int>? onStepTapped;

  /// Height. Defaults to 72 (88 for numbered).
  final double? height;

  /// Duration of the progress animation.
  final Duration duration;

  /// Creates a step indicator.
  const AwesomeStepIndicator({
    super.key,
    required this.currentStep,
    this.labels,
    this.totalSteps,
    this.type = AwesomeStepperHeader.bar,
    this.color,
    this.background,
    this.lineStyle = AwesomeStepperLineStyle.solid,
    this.onStepTapped,
    this.height,
    this.duration = const Duration(milliseconds: 400),
  }) : assert(
         labels != null || totalSteps != null,
         'Pass labels or totalSteps',
       );

  @override
  State<AwesomeStepIndicator> createState() => _AwesomeStepIndicatorState();
}

class _AwesomeStepIndicatorState extends State<AwesomeStepIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;

  int get _total => widget.labels?.length ?? widget.totalSteps!;
  double get _target => ((widget.currentStep + 1) / _total).clamp(0, 1);

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: widget.duration)
      ..animateTo(_target);
  }

  @override
  void didUpdateWidget(AwesomeStepIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep ||
        oldWidget.labels?.length != widget.labels?.length) {
      _progress.animateTo(_target);
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AwesomeStepperTheme>();
    final current = widget.currentStep.clamp(0, _total - 1);
    final data = StepperHeaderData(
      steps: [
        for (var i = 0; i < _total; i++)
          AwesomeStepperItem(
            label: widget.labels?[i] ?? '',
            content: const SizedBox(),
          ),
      ],
      statuses: [
        for (var i = 0; i < _total; i++)
          i < current
              ? AwesomeStepStatus.completed
              : i == current
              ? AwesomeStepStatus.active
              : AwesomeStepStatus.upcoming,
      ],
      current: current,
      progress: _progress,
      background: widget.background ?? Colors.transparent,
      accent:
          widget.color ??
          theme?.accentColor ??
          Theme.of(context).colorScheme.primary,
      titleStyle: theme?.titleStyle,
      progressStyle: theme?.progressStyle,
      titleDuration: const Duration(milliseconds: 250),
      onTap: widget.onStepTapped ?? (_) {},
      lineStyle: widget.lineStyle,
    );
    return Semantics(
      label: 'Step ${current + 1} of $_total',
      child: StepperHeader(
        type: widget.type,
        data: data,
        height:
            widget.height ??
            (widget.type == AwesomeStepperHeader.numbered ? 88 : 72),
      ),
    );
  }
}
