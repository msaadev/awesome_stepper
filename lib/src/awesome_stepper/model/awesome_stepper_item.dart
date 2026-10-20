import 'dart:async';

import 'package:flutter/widgets.dart';

/// One step of an `AwesomeStepper`.
class AwesomeStepperItem {
  /// Title shown in the header while this step is active.
  final String label;

  /// The page shown while this step is active.
  final Widget content;

  /// Optional second line under [label] (numbered header and side list).
  final String? subtitle;

  /// Optional icon shown instead of the step number in the side list.
  final IconData? icon;

  /// Checked before leaving this step forward. Return `false` to stay on the
  /// step and mark it as an error (for example, when a form is invalid).
  final FutureOr<bool> Function()? canContinue;

  /// Disabled steps are skipped by next / back and shown as locked.
  final bool enabled;

  /// Optional steps show a Skip button that moves on without `canContinue`.
  final bool optional;

  /// Creates a step.
  const AwesomeStepperItem({
    required this.label,
    required this.content,
    this.subtitle,
    this.icon,
    this.canContinue,
    this.enabled = true,
    this.optional = false,
  });
}

/// Header styles of an `AwesomeStepper`.
enum AwesomeStepperHeader {
  /// Progress circle with "current / total" and the step title (the classic look).
  circle,

  /// Linear progress bar under the step title.
  bar,

  /// One dot per step; the active one stretches into a pill.
  dots,

  /// Numbered steps with connectors; completed steps can be tapped.
  numbered,
}

/// Visual state of a step, used by the headers and the side list.
enum AwesomeStepStatus {
  /// Not reached yet.
  upcoming,

  /// The step on screen.
  active,

  /// Passed.
  completed,

  /// Its `canContinue` check failed.
  error,

  /// Disabled.
  locked,
}

/// How the steps are laid out.
enum AwesomeStepperLayout {
  /// A header on top and one page at a time (the default).
  horizontal,

  /// Steps listed top to bottom; the active step opens in place, like a
  /// checkout or settings wizard. Step content must size itself (no
  /// `Expanded` or unbounded lists at its root).
  vertical,
}

/// Page transition between steps.
enum AwesomeStepperTransition {
  /// Slide in the direction of travel, with a fade (the default).
  slide,

  /// Cross-fade.
  fade,

  /// Fade with a slight zoom.
  scale,

  /// No animation.
  none,
}

/// Style of the lines that connect steps.
enum AwesomeStepperLineStyle {
  /// A continuous line.
  solid,

  /// Round dots.
  dotted,

  /// Short dashes.
  dashed,
}
