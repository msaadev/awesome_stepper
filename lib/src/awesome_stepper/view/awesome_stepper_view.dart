import 'dart:async';
import 'dart:ui' show DisplayFeatureType;

import 'package:awesome_stepper/src/awesome_stepper/model/awesome_stepper_item.dart';
import 'package:awesome_stepper/src/awesome_stepper/view/stepper_headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part '../controller/awesome_stepper_controller.dart';

/// A stepper with an animated progress header, sliding pages and
/// back / next controls.
///
/// On wide windows (see [sideBySideMinWidth]) the steps move into a side
/// list; on foldables the split follows the vertical fold.
class AwesomeStepper extends StatefulWidget {
  /// The steps to show, in order. Must not be empty.
  final List<AwesomeStepperItem> steps;

  /// Moves the stepper from code; optional.
  final AwesomeStepperController? controller;

  /// Called with the new step index after every step change.
  final ValueChanged<int>? onStepChanged;

  /// Called when Next / Finish is tapped on the last step and its
  /// `canContinue` check passes.
  final VoidCallback? onCompleted;

  /// Header style. Defaults to the classic progress circle.
  final AwesomeStepperHeader headerType;

  /// Background color of the header. Defaults to the theme's surface container.
  final Color? headerColor;

  /// Color of the progress indicator and active step. Defaults to the
  /// theme's primary color.
  final Color? progressColor;

  /// Text style of the step title in the header.
  final TextStyle? headerStyle;

  /// Text style of the "current / total" text.
  final TextStyle? progressStyle;

  /// Height of the header. Defaults to 72 (88 for [AwesomeStepperHeader.numbered]).
  final double? headerHeight;

  /// Minimum height of the default back / next buttons. Defaults to 48.
  final double? controllerHeight;

  /// Duration of the step title cross-fade. Defaults to 250 ms.
  final Duration? headerAnimationDuration;

  /// Duration of the progress animation. Defaults to 1 s.
  final Duration? progressBarAnimationDuration;

  /// Duration of the page slide between steps. Defaults to 300 ms.
  final Duration contentAnimationDuration;

  /// Builds custom controls instead of the default back / next buttons.
  final Widget Function(VoidCallback onNextTapped, VoidCallback onBackTapped)?
  controlBuilder;

  /// Label of the default next button.
  final String nextLabel;

  /// Label of the default back button.
  final String backLabel;

  /// Label of the default next button on the last step.
  final String finishLabel;

  /// Screen reader text for the active step. Defaults to
  /// "Step {step} of {total}: {label}".
  final String Function(int step, int total, String label)? semanticsLabel;

  /// Swipe left / right on the page to go next / back.
  final bool swipeEnabled;

  /// Arrow keys go next / back (web, desktop, hardware keyboards).
  final bool keyboardEnabled;

  /// Light haptic feedback on step changes and failed checks.
  final bool hapticsEnabled;

  /// From this width on, the steps are shown in a side list next to the page.
  /// `null` keeps the header layout at every width.
  final double? sideBySideMinWidth;

  /// Width of the side list when there is no fold to align to.
  final double sideListWidth;

  /// Creates a stepper for [steps].
  const AwesomeStepper({
    super.key,
    required this.steps,
    this.controller,
    this.onStepChanged,
    this.onCompleted,
    this.headerType = AwesomeStepperHeader.circle,
    this.headerColor,
    this.headerStyle,
    this.progressStyle,
    this.headerAnimationDuration,
    this.progressBarAnimationDuration,
    this.contentAnimationDuration = const Duration(milliseconds: 300),
    this.controlBuilder,
    this.progressColor,
    this.headerHeight,
    this.controllerHeight,
    this.nextLabel = 'Next',
    this.backLabel = 'Back',
    this.finishLabel = 'Finish',
    this.semanticsLabel,
    this.swipeEnabled = true,
    this.keyboardEnabled = true,
    this.hapticsEnabled = true,
    this.sideBySideMinWidth = 840,
    this.sideListWidth = 300,
  });

  @override
  State<AwesomeStepper> createState() => _AwesomeStepperState();
}

class _AwesomeStepperState extends State<AwesomeStepper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late AwesomeStepperController _controller;
  AwesomeStepperController? _ownController;
  final Set<int> _errors = {};
  bool _busy = false;
  bool _forward = true;
  Timer? _introTimer;

  int get _step => _controller.currentStep;

  // The side list already is a circle + numbered list; bar and dots add their own look on top of the page.
  bool get _showsHeaderBesideList =>
      widget.headerType == AwesomeStepperHeader.bar ||
      widget.headerType == AwesomeStepperHeader.dots;
  double get _ratio => 1 / widget.steps.length;

  @override
  void initState() {
    super.initState();
    assert(widget.steps.isNotEmpty, 'steps must not be empty');
    _attach(widget.controller);
    _progressController = AnimationController(
      duration:
          widget.progressBarAnimationDuration ?? const Duration(seconds: 1),
      vsync: this,
    );
    _introTimer = Timer(const Duration(milliseconds: 500), () {
      _progressController.animateTo((_step + 1) * _ratio);
    });
  }

  @override
  void didUpdateWidget(AwesomeStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detach();
      _attach(widget.controller);
    }
    if (_step >= widget.steps.length) _controller._set(widget.steps.length - 1);
  }

  @override
  void dispose() {
    _introTimer?.cancel();
    _detach();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _headerData(context);
    final body = LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = widget.sideBySideMinWidth;
        if (minWidth == null || constraints.maxWidth < minWidth) {
          return _buildStacked(data);
        }
        return _buildSideBySide(context, data, constraints);
      },
    );
    if (!widget.keyboardEnabled) return body;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): rtl
            ? _back
            : _next,
        const SingleActivator(LogicalKeyboardKey.arrowLeft): rtl
            ? _next
            : _back,
      },
      child: Focus(child: body),
    );
  }

  Widget _buildStacked(StepperHeaderData data) {
    return Column(
      children: [
        _buildSemantics(_buildHeader(data)),
        Expanded(child: _buildPage()),
        _buildControls(),
      ],
    );
  }

  Widget _buildSideBySide(
    BuildContext context,
    StepperHeaderData data,
    BoxConstraints constraints,
  ) {
    final fold = _verticalFold(context, constraints);
    return Row(
      children: [
        SizedBox(
          width: fold?.left ?? widget.sideListWidth,
          child: _buildSemantics(StepperSideList(data: data)),
        ),
        if (fold != null)
          SizedBox(width: fold.width)
        else
          const VerticalDivider(width: 1),
        Expanded(
          child: Column(
            children: [
              if (_showsHeaderBesideList) _buildHeader(data),
              Expanded(child: _buildPage()),
              _buildControls(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(StepperHeaderData data) {
    final type = widget.headerType;
    return StepperHeader(
      type: type,
      data: data,
      height:
          widget.headerHeight ??
          (type == AwesomeStepperHeader.numbered ? 88 : 72),
    );
  }

  Widget _buildSemantics(Widget child) {
    final step = widget.steps[_step];
    final total = widget.steps.length;
    final label =
        widget.semanticsLabel?.call(_step + 1, total, step.label) ??
        'Step ${_step + 1} of $total: ${step.label}';
    return Semantics(
      container: true,
      liveRegion: true,
      label: label,
      child: child,
    );
  }

  Widget _buildPage() {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final page = AnimatedSwitcher(
      duration: widget.contentAnimationDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final incoming = child.key == ValueKey(_step);
        var dx = (_forward == incoming) ? 0.12 : -0.12;
        if (rtl) dx = -dx;
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(
              begin: Offset(dx, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(_step),
        child: widget.steps[_step].content,
      ),
    );
    if (!widget.swipeEnabled) return page;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity.abs() < 300) return;
        final towardNext = rtl ? velocity > 0 : velocity < 0;
        towardNext ? _next() : _back();
      },
      child: page,
    );
  }

  Widget _buildControls() {
    final builder = widget.controlBuilder;
    if (builder != null) return builder(_next, _back);
    final size = Size(64, widget.controllerHeight ?? 48);
    final isFirst = _neighbour(-1) == null;
    final isLast = _neighbour(1) == null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: size),
            onPressed: isFirst || _busy ? null : _back,
            child: Text(widget.backLabel),
          ),
          const Spacer(),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: size,
              backgroundColor: widget.progressColor,
            ),
            onPressed: _busy ? null : _next,
            child: _busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isLast ? widget.finishLabel : widget.nextLabel),
          ),
        ],
      ),
    );
  }

  StepperHeaderData _headerData(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return StepperHeaderData(
      steps: widget.steps,
      statuses: [for (var i = 0; i < widget.steps.length; i++) _statusOf(i)],
      current: _step,
      progress: _progressController,
      background: widget.headerColor ?? scheme.surfaceContainerLow,
      accent: widget.progressColor ?? scheme.primary,
      titleStyle: widget.headerStyle,
      progressStyle: widget.progressStyle,
      titleDuration:
          widget.headerAnimationDuration ?? const Duration(milliseconds: 250),
      onTap: _jumpTo,
    );
  }

  AwesomeStepStatus _statusOf(int index) {
    if (!widget.steps[index].enabled) return AwesomeStepStatus.locked;
    if (_errors.contains(index)) return AwesomeStepStatus.error;
    if (index == _step) return AwesomeStepStatus.active;
    if (index < _step) return AwesomeStepStatus.completed;
    return AwesomeStepStatus.upcoming;
  }

  // shortcut: assumes the stepper spans the window width (the usual case);
  // a stepper inside a narrower pane ignores the fold.
  Rect? _verticalFold(BuildContext context, BoxConstraints constraints) {
    if (constraints.maxWidth != MediaQuery.sizeOf(context).width) return null;
    for (final feature in MediaQuery.displayFeaturesOf(context)) {
      final bounds = feature.bounds;
      final isFold =
          feature.type == DisplayFeatureType.fold ||
          feature.type == DisplayFeatureType.hinge;
      if (isFold && bounds.height > bounds.width && bounds.left > 0) {
        return bounds;
      }
    }
    return null;
  }

  void _attach(AwesomeStepperController? controller) {
    if (controller == null) {
      _ownController = AwesomeStepperController();
      controller = _ownController!;
    }
    _controller = controller;
    _controller._state = this;
    final last = widget.steps.length - 1;
    if (_step > last) _controller._set(last);
    _controller.addListener(_onControllerChanged);
  }

  void _detach() {
    _controller.removeListener(_onControllerChanged);
    if (_controller._state == this) _controller._state = null;
    _ownController?.dispose();
    _ownController = null;
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  int? _neighbour(int direction) {
    for (
      var i = _step + direction;
      i >= 0 && i < widget.steps.length;
      i += direction
    ) {
      if (widget.steps[i].enabled) return i;
    }
    return null;
  }

  Future<bool> _next() async {
    final target = _neighbour(1);
    if (target != null) return _jumpTo(target);
    if (_busy || !await _validate(_step)) return false;
    widget.onCompleted?.call();
    return true;
  }

  Future<bool> _back() async {
    final target = _neighbour(-1);
    return target == null ? false : _jumpTo(target);
  }

  Future<bool> _jumpTo(int target) async {
    final valid =
        target >= 0 &&
        target < widget.steps.length &&
        target != _step &&
        widget.steps[target].enabled;
    if (_busy || !valid) return false;
    for (var i = _step; i < target; i++) {
      if (!widget.steps[i].enabled) continue;
      if (await _validate(i)) continue;
      if (i != _step) _show(i);
      return false;
    }
    _show(target);
    return true;
  }

  Future<bool> _validate(int index) async {
    final check = widget.steps[index].canContinue;
    if (check == null) return true;
    setState(() => _busy = true);
    final ok = await check();
    if (!mounted) return false;
    setState(() {
      _busy = false;
      ok ? _errors.remove(index) : _errors.add(index);
    });
    if (!ok && widget.hapticsEnabled) HapticFeedback.lightImpact();
    return ok;
  }

  void _show(int target) {
    _forward = target > _step;
    _progressController.animateTo((target + 1) * _ratio);
    _controller._set(target);
    if (widget.hapticsEnabled) HapticFeedback.selectionClick();
    widget.onStepChanged?.call(target);
  }
}
