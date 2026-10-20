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

  /// Creates a step.
  const AwesomeStepperItem({
    required this.label,
    required this.content,
    this.subtitle,
    this.icon,
    this.canContinue,
    this.enabled = true,
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
