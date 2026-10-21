import 'dart:async';
import 'dart:ui' show DisplayFeatureType;

import 'package:awesome_stepper/src/awesome_stepper/model/awesome_stepper_item.dart';
import 'package:awesome_stepper/src/awesome_stepper/model/awesome_stepper_theme.dart';
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

  /// From this width on, the `circle` and `numbered` headers turn into a side
  /// list next to the page (`bar` and `dots` stay as they are).
  /// `null` keeps the header layout at every width.
  final double? sideBySideMinWidth;

  /// Width of the side list when there is no fold to align to.
  final double sideListWidth;

  /// Maximum width of the page, the controls and the header content on wide
  /// windows, so forms keep a readable line length. Phones are narrower, so
  /// nothing changes there.
  final double contentMaxWidth;

  /// Header on top with one page at a time, or steps listed vertically.
  final AwesomeStepperLayout layout;

  /// Page transition between steps.
  final AwesomeStepperTransition transition;

  /// Style of the lines between steps (numbered header and vertical layout).
  final AwesomeStepperLineStyle lineStyle;

  /// Label of the Skip button shown on optional steps.
  final String skipLabel;

  /// Whether tapping a later step in the header may jump forward
  /// (still running each step's `canContinue`). Going back is always allowed.
  final bool allowHeaderJump;

  /// Shown instead of the page after the last step is finished, for a
  /// summary or thank-you screen. Back returns to the last step.
  final WidgetBuilder? completedBuilder;

  /// Restores the active step after the app is killed and reopened
  /// (needs a `restorationScopeId` on your `MaterialApp`).
  final String? restorationId;

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
    this.contentMaxWidth = 720,
    this.layout = AwesomeStepperLayout.horizontal,
    this.transition = AwesomeStepperTransition.slide,
    this.lineStyle = AwesomeStepperLineStyle.solid,
    this.skipLabel = 'Skip',
    this.allowHeaderJump = true,
    this.completedBuilder,
    this.restorationId,
  });

  @override
  State<AwesomeStepper> createState() => _AwesomeStepperState();
}

class _AwesomeStepperState extends State<AwesomeStepper>
    with SingleTickerProviderStateMixin, RestorationMixin {
  late final AnimationController _progressController;
  late AwesomeStepperController _controller;
  AwesomeStepperController? _ownController;
  final Set<int> _errors = {};
  bool _busy = false;
  bool _forward = true;
  Timer? _introTimer;
  bool _completed = false;
  final RestorableInt _restoredStep = RestorableInt(0);

  int get _step => _controller.currentStep;

  // Bar and dots keep their own look on every width; circle and numbered become the side list.
  bool get _usesSideList =>
      widget.headerType == AwesomeStepperHeader.circle ||
      widget.headerType == AwesomeStepperHeader.numbered;
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
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_restoredStep, 'step');
    if (oldBucket == null && initialRestore && _restoredStep.value == 0) return;
    _controller._set(_restoredStep.value.clamp(0, widget.steps.length - 1));
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
    _restoredStep.dispose();
    _detach();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _headerData(context);
    final body = widget.layout == AwesomeStepperLayout.vertical
        ? _buildVertical(data)
        : LayoutBuilder(
            builder: (context, constraints) {
              final minWidth = widget.sideBySideMinWidth;
              if (!_usesSideList ||
                  minWidth == null ||
                  constraints.maxWidth < minWidth) {
                return _buildStacked(data, constraints.maxWidth);
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
      child: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): _EnterIntent(),
          SingleActivator(LogicalKeyboardKey.numpadEnter): _EnterIntent(),
        },
        child: Actions(
          actions: {_EnterIntent: _EnterAction(_next)},
          child: Focus(child: body),
        ),
      ),
    );
  }

  Widget _buildStacked(StepperHeaderData data, double width) {
    return Column(
      children: [
        _buildSemantics(_buildHeader(data, width)),
        Expanded(child: _constrain(_buildPage(), fillHeight: true)),
        _constrain(_buildControls()),
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
              Expanded(child: _constrain(_buildPage(), fillHeight: true)),
              _constrain(_buildControls()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVertical(StepperHeaderData data) {
    final completed = _completed && widget.completedBuilder != null;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.contentMaxWidth),
        child: _buildSemantics(
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              for (var i = 0; i < widget.steps.length; i++)
                _buildVerticalStep(data, i),
              if (completed)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: widget.completedBuilder!(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalStep(StepperHeaderData data, int index) {
    final step = widget.steps[index];
    final status = data.statuses[index];
    final active = index == _step && !_completed;
    final isLast = index == widget.steps.length - 1;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: status == AwesomeStepStatus.locked
              ? null
              : () => _onHeaderTap(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                StatusBadge(
                  index: index,
                  status: status,
                  accent: data.accent,
                  icon: step.icon,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.label,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: active ? FontWeight.w600 : null,
                        ),
                      ),
                      if (step.subtitle != null)
                        Text(step.subtitle!, style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Stack(
          children: [
            if (!isLast)
              Positioned(
                left: 15,
                top: 0,
                bottom: 0,
                child: CustomPaint(
                  painter: StepLinePainter(
                    color: status == AwesomeStepStatus.completed
                        ? data.accent
                        : scheme.outlineVariant,
                    style: widget.lineStyle,
                  ),
                  child: const SizedBox(width: 2),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: AnimatedSize(
                duration: widget.contentAnimationDuration,
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: active
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [step.content, _buildControls()],
                      )
                    : SizedBox(width: double.infinity, height: isLast ? 0 : 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(StepperHeaderData data, double width) {
    final type = widget.headerType;
    final wide = width >= StepperHeader.wideDotsMinWidth;
    return StepperHeader(
      type: type,
      data: data,
      maxContentWidth: widget.contentMaxWidth,
      wide: wide,
      height:
          widget.headerHeight ??
          (type == AwesomeStepperHeader.numbered ||
                  (type == AwesomeStepperHeader.dots && wide)
              ? 88
              : 72),
    );
  }

  // The page fills the column's height; the controls only need its width.
  Widget _constrain(Widget child, {bool fillHeight = false}) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.contentMaxWidth),
        child: SizedBox(
          width: double.infinity,
          height: fillHeight ? double.infinity : null,
          child: child,
        ),
      ),
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
    final completed = _completed && widget.completedBuilder != null;
    final page = AnimatedSwitcher(
      duration: widget.transition == AwesomeStepperTransition.none
          ? Duration.zero
          : widget.contentAnimationDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      // Top-aligned so self-sized pages (a Column form) start at the top, not mid-screen.
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, animation) {
        switch (widget.transition) {
          case AwesomeStepperTransition.none:
            return child;
          case AwesomeStepperTransition.fade:
            return FadeTransition(opacity: animation, child: child);
          case AwesomeStepperTransition.scale:
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween(begin: 0.96, end: 1.0).animate(animation),
                child: child,
              ),
            );
          case AwesomeStepperTransition.slide:
            final incoming = child.key == ValueKey(completed ? -1 : _step);
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
        }
      },
      child: KeyedSubtree(
        key: ValueKey(completed ? -1 : _step),
        child: completed
            ? widget.completedBuilder!(context)
            : widget.steps[_step].content,
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
    if (_completed && widget.completedBuilder != null) {
      return const SizedBox.shrink();
    }
    final builder = widget.controlBuilder;
    if (builder != null) return builder(_next, _back);
    final theme = Theme.of(context).extension<AwesomeStepperTheme>();
    final size = Size(64, widget.controllerHeight ?? theme?.buttonHeight ?? 48);
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
          if (widget.steps[_step].optional)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: size),
                onPressed: _busy ? null : _skip,
                child: Text(widget.skipLabel),
              ),
            ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: size,
              backgroundColor: widget.progressColor ?? theme?.accentColor,
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
    final theme = Theme.of(context).extension<AwesomeStepperTheme>();
    return StepperHeaderData(
      steps: widget.steps,
      statuses: [for (var i = 0; i < widget.steps.length; i++) _statusOf(i)],
      current: _step,
      progress: _progressController,
      background:
          widget.headerColor ??
          theme?.headerColor ??
          scheme.surfaceContainerLow,
      accent: widget.progressColor ?? theme?.accentColor ?? scheme.primary,
      titleStyle: widget.headerStyle ?? theme?.titleStyle,
      progressStyle: widget.progressStyle ?? theme?.progressStyle,
      lineStyle: widget.lineStyle,
      titleDuration:
          widget.headerAnimationDuration ?? const Duration(milliseconds: 250),
      onTap: _onHeaderTap,
    );
  }

  AwesomeStepStatus _statusOf(int index) {
    if (!widget.steps[index].enabled) return AwesomeStepStatus.locked;
    if (_errors.contains(index)) return AwesomeStepStatus.error;
    if (_completed) return AwesomeStepStatus.completed;
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
    if (_completed) return false;
    final target = _neighbour(1);
    if (target != null) return _jumpTo(target);
    if (_busy || !await _validate(_step)) return false;
    _complete();
    return true;
  }

  Future<bool> _skip() async {
    if (_busy || _completed) return false;
    setState(() => _errors.remove(_step));
    final target = _neighbour(1);
    if (target == null) {
      _complete();
    } else {
      _show(target);
    }
    return true;
  }

  void _complete() {
    widget.onCompleted?.call();
    if (widget.completedBuilder == null) return;
    _forward = true;
    _progressController.animateTo(1);
    setState(() => _completed = true);
  }

  void _onHeaderTap(int index) {
    if (!widget.allowHeaderJump && index > _step) return;
    if (_completed) setState(() => _completed = false);
    _jumpTo(index);
  }

  Future<bool> _back() async {
    if (_completed) {
      _forward = false;
      _progressController.animateTo((_step + 1) * _ratio);
      setState(() => _completed = false);
      return true;
    }
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
    var ok = false;
    try {
      ok = await check();
    } catch (error, stack) {
      // A throwing check (e.g. a failed request) counts as "not valid" and must not lock the buttons.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'awesome_stepper',
          context: ErrorDescription('while running canContinue of step $index'),
        ),
      );
    }
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
    _restoredStep.value = target;
    if (widget.hapticsEnabled) HapticFeedback.selectionClick();
    widget.onStepChanged?.call(target);
  }
}

class _EnterIntent extends Intent {
  const _EnterIntent();
}

class _EnterAction extends Action<_EnterIntent> {
  final VoidCallback onEnter;

  _EnterAction(this.onEnter);

  // A disabled action lets Enter reach the text field to insert a new line.
  @override
  bool isEnabled(_EnterIntent intent) {
    final context = FocusManager.instance.primaryFocus?.context;
    final editable = context?.findAncestorWidgetOfExactType<EditableText>();
    return editable == null || editable.maxLines == 1;
  }

  @override
  void invoke(_EnterIntent intent) => onEnter();
}
