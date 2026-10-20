import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// App-wide defaults for every `AwesomeStepper` and `AwesomeStepIndicator`.
/// Values passed to a widget win over the theme.
///
/// ```dart
/// ThemeData(extensions: const [AwesomeStepperTheme(accentColor: Colors.teal)])
/// ```
@immutable
class AwesomeStepperTheme extends ThemeExtension<AwesomeStepperTheme> {
  /// Header background.
  final Color? headerColor;

  /// Progress, active step and Next button color.
  final Color? accentColor;

  /// Step title text style.
  final TextStyle? titleStyle;

  /// "current / total" text style.
  final TextStyle? progressStyle;

  /// Minimum height of the Back / Next buttons.
  final double? buttonHeight;

  /// Creates a stepper theme.
  const AwesomeStepperTheme({
    this.headerColor,
    this.accentColor,
    this.titleStyle,
    this.progressStyle,
    this.buttonHeight,
  });

  @override
  AwesomeStepperTheme copyWith({
    Color? headerColor,
    Color? accentColor,
    TextStyle? titleStyle,
    TextStyle? progressStyle,
    double? buttonHeight,
  }) {
    return AwesomeStepperTheme(
      headerColor: headerColor ?? this.headerColor,
      accentColor: accentColor ?? this.accentColor,
      titleStyle: titleStyle ?? this.titleStyle,
      progressStyle: progressStyle ?? this.progressStyle,
      buttonHeight: buttonHeight ?? this.buttonHeight,
    );
  }

  @override
  AwesomeStepperTheme lerp(AwesomeStepperTheme? other, double t) {
    if (other == null) return this;
    return AwesomeStepperTheme(
      headerColor: Color.lerp(headerColor, other.headerColor, t),
      accentColor: Color.lerp(accentColor, other.accentColor, t),
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t),
      progressStyle: TextStyle.lerp(progressStyle, other.progressStyle, t),
      buttonHeight: lerpDouble(buttonHeight, other.buttonHeight, t),
    );
  }
}
