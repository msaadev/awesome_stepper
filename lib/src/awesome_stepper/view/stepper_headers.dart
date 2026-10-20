import 'package:awesome_stepper/src/awesome_stepper/model/awesome_stepper_item.dart';
import 'package:flutter/material.dart';

/// Everything a header needs; built once per frame by the stepper.
class StepperHeaderData {
  final List<AwesomeStepperItem> steps;
  final List<AwesomeStepStatus> statuses;
  final int current;
  final Animation<double> progress;
  final Color background;
  final Color accent;
  final TextStyle? titleStyle;
  final TextStyle? progressStyle;
  final Duration titleDuration;
  final ValueChanged<int> onTap;
  final AwesomeStepperLineStyle lineStyle;

  const StepperHeaderData({
    required this.steps,
    required this.statuses,
    required this.current,
    required this.progress,
    required this.background,
    required this.accent,
    required this.titleStyle,
    required this.progressStyle,
    required this.titleDuration,
    required this.onTap,
    this.lineStyle = AwesomeStepperLineStyle.solid,
  });

  String get counter => '${current + 1} / ${steps.length}';
}

/// The horizontal header above the content.
class StepperHeader extends StatelessWidget {
  final AwesomeStepperHeader type;
  final StepperHeaderData data;
  final double height;
  final double maxContentWidth;

  const StepperHeader({
    super.key,
    required this.type,
    required this.data,
    required this.height,
    this.maxContentWidth = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: data.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: switch (type) {
          AwesomeStepperHeader.circle => _buildCircle(),
          AwesomeStepperHeader.bar => _buildBar(context),
          AwesomeStepperHeader.dots => _buildDots(context),
          AwesomeStepperHeader.numbered => _buildNumbered(context),
        },
      ),
    );
  }

  Widget _buildCircle() {
    return Row(
      children: [
        AspectRatio(aspectRatio: 1, child: ProgressCircle(data: data)),
        const SizedBox(width: 16),
        Expanded(child: StepTitle(data: data)),
      ],
    );
  }

  Widget _buildBar(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: StepTitle(data: data, align: TextAlign.start),
            ),
            Text(
              data.counter,
              style:
                  data.progressStyle ?? Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: data.progress,
          builder: (_, _) => LinearProgressIndicator(
            value: data.progress.value,
            minHeight: 6,
            color: data.accent,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  Widget _buildDots(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StepTitle(data: data),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < data.steps.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: i == data.current ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor(data.statuses[i], data.accent, scheme),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumbered(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < data.steps.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: CustomPaint(
                      size: const Size(24, 2),
                      painter: StepLinePainter(
                        color:
                            data.statuses[i - 1] == AwesomeStepStatus.completed
                            ? data.accent
                            : scheme.outlineVariant,
                        style: data.lineStyle,
                      ),
                    ),
                  ),
                _buildNumberedStep(context, i),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberedStep(BuildContext context, int index) {
    final step = data.steps[index];
    final status = data.statuses[index];
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: status == AwesomeStepStatus.locked
          ? null
          : () => data.onTap(index),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, maxWidth: 96),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusBadge(
              index: index,
              status: status,
              accent: data.accent,
              icon: step.icon,
            ),
            const SizedBox(height: 4),
            Text(
              step.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: index == data.current ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The vertical step list used on wide screens.
class StepperSideList extends StatelessWidget {
  final StepperHeaderData data;

  const StepperSideList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: data.background,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: SizedBox.square(
              dimension: 96,
              child: ProgressCircle(data: data, strokeWidth: 8),
            ),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < data.steps.length; i++)
            ListTile(
              selected: i == data.current,
              enabled: data.statuses[i] != AwesomeStepStatus.locked,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: StatusBadge(
                index: i,
                status: data.statuses[i],
                accent: data.accent,
                icon: data.steps[i].icon,
              ),
              title: Text(data.steps[i].label, style: textTheme.titleSmall),
              subtitle: data.steps[i].subtitle == null
                  ? null
                  : Text(data.steps[i].subtitle!),
              onTap: () => data.onTap(i),
            ),
        ],
      ),
    );
  }
}

/// The classic Awesome Stepper progress circle with "current / total".
class ProgressCircle extends StatelessWidget {
  final StepperHeaderData data;
  final double strokeWidth;

  const ProgressCircle({super.key, required this.data, this.strokeWidth = 5});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: data.progress,
          builder: (_, _) => CircularProgressIndicator(
            value: data.progress.value,
            color: data.accent,
            backgroundColor: scheme.surfaceContainerHighest,
            strokeWidth: strokeWidth,
            strokeCap: StrokeCap.round,
          ),
        ),
        Center(
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                data.counter,
                style:
                    data.progressStyle ??
                    Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The active step's title (and subtitle), cross-fading on change.
class StepTitle extends StatelessWidget {
  final StepperHeaderData data;
  final TextAlign align;

  const StepTitle({
    super.key,
    required this.data,
    this.align = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final step = data.steps[data.current];
    final textTheme = Theme.of(context).textTheme;
    return AnimatedSwitcher(
      duration: data.titleDuration,
      layoutBuilder: (current, previous) => Stack(
        alignment: align == TextAlign.center
            ? Alignment.center
            : AlignmentDirectional.centerStart,
        children: [...previous, ?current],
      ),
      child: Column(
        key: ValueKey(data.current),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: align == TextAlign.center
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            step.label,
            textAlign: align,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: data.titleStyle ?? textTheme.titleMedium,
          ),
          if (step.subtitle != null)
            Text(
              step.subtitle!,
              textAlign: align,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

/// Number, check, error or lock badge of one step.
class StatusBadge extends StatelessWidget {
  final int index;
  final AwesomeStepStatus status;
  final Color accent;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.index,
    required this.status,
    required this.accent,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filled =
        status == AwesomeStepStatus.active ||
        status == AwesomeStepStatus.completed ||
        status == AwesomeStepStatus.error;
    final fill = statusColor(status, accent, scheme);
    final onFill = ThemeData.estimateBrightnessForColor(fill) == Brightness.dark
        ? Colors.white
        : Colors.black;
    final foreground = filled ? onFill : scheme.onSurfaceVariant;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? fill : null,
        border: filled
            ? null
            : Border.all(color: scheme.outlineVariant, width: 2),
      ),
      child: switch (status) {
        AwesomeStepStatus.completed => Icon(
          Icons.check_rounded,
          size: 18,
          color: foreground,
        ),
        AwesomeStepStatus.error => Icon(
          Icons.priority_high_rounded,
          size: 18,
          color: foreground,
        ),
        AwesomeStepStatus.locked => Icon(
          Icons.lock_outline_rounded,
          size: 16,
          color: foreground,
        ),
        _ =>
          icon != null
              ? Icon(icon, size: 18, color: foreground)
              : Text(
                  '${index + 1}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: foreground),
                ),
      },
    );
  }
}

/// Fill color for a step in the given [status].
Color statusColor(AwesomeStepStatus status, Color accent, ColorScheme scheme) {
  return switch (status) {
    AwesomeStepStatus.active || AwesomeStepStatus.completed => accent,
    AwesomeStepStatus.error => scheme.error,
    AwesomeStepStatus.locked => scheme.outlineVariant.withValues(alpha: 0.5),
    AwesomeStepStatus.upcoming => scheme.outlineVariant,
  };
}

/// Draws a solid, dotted or dashed line along the longer side of its size.
class StepLinePainter extends CustomPainter {
  final Color color;
  final AwesomeStepperLineStyle style;

  const StepLinePainter({required this.color, required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final horizontal = size.width >= size.height;
    final thickness = horizontal ? size.height : size.width;
    final length = horizontal ? size.width : size.height;
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = style == AwesomeStepperLineStyle.dotted
          ? StrokeCap.round
          : StrokeCap.butt;
    Offset at(double d) =>
        horizontal ? Offset(d, size.height / 2) : Offset(size.width / 2, d);
    if (style == AwesomeStepperLineStyle.solid) {
      canvas.drawLine(at(0), at(length), paint);
      return;
    }
    final dash = style == AwesomeStepperLineStyle.dashed ? 6.0 : 0.1;
    final gap = style == AwesomeStepperLineStyle.dashed ? 4.0 : thickness * 2.5;
    for (var d = 0.0; d < length; d += dash + gap) {
      canvas.drawLine(at(d), at((d + dash).clamp(0, length)), paint);
    }
  }

  @override
  bool shouldRepaint(StepLinePainter old) =>
      old.color != color || old.style != style;
}
