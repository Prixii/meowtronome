import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meowtronome/ui/components/animated_list.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({
    super.key,
    this.vertical = false,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  });

  final bool vertical;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return vertical
        ? VerticalDivider(
            color: color ?? Theme.of(context).colorScheme.primary,
            thickness: thickness,
            indent: indent,
            width: 1,
            endIndent: endIndent,
          )
        : Divider(
            color: color ?? Theme.of(context).colorScheme.primary,
            thickness: thickness,
            indent: indent,
            height: 1,
            endIndent: endIndent,
          );
  }
}

class AnimatedCustomDivider extends StatefulWidget {
  const AnimatedCustomDivider({
    super.key,
    this.vertical = false,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
    this.duration = kAnimatedListDuration,
    this.curve = kAnimatedListCurve,
  });

  final bool vertical;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;
  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedCustomDivider> createState() => _AnimatedCustomDividerState();
}

class _AnimatedCustomDividerState extends State<AnimatedCustomDivider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late CurvedAnimation _animation;

  late double _indentBegin;
  late double _indentEnd;
  late double _endIndentBegin;
  late double _endIndentEnd;
  late double _thicknessBegin;
  late double _thicknessEnd;
  Color? _colorBegin;
  Color? _colorEnd;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..value = 1;
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    _indentBegin = _indentEnd = widget.indent;
    _endIndentBegin = _endIndentEnd = widget.endIndent;
    _thicknessBegin = _thicknessEnd = widget.thickness;
    _colorBegin = _colorEnd = widget.color;
  }

  @override
  void didUpdateWidget(covariant AnimatedCustomDivider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.curve != widget.curve) {
      _animation.dispose();
      _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    }

    final changed =
        oldWidget.indent != widget.indent ||
        oldWidget.endIndent != widget.endIndent ||
        oldWidget.thickness != widget.thickness ||
        oldWidget.color != widget.color;

    if (!changed) {
      return;
    }

    final t = _animation.value;
    _indentBegin = lerpDouble(_indentBegin, _indentEnd, t)!;
    _endIndentBegin = lerpDouble(_endIndentBegin, _endIndentEnd, t)!;
    _thicknessBegin = lerpDouble(_thicknessBegin, _thicknessEnd, t)!;
    _colorBegin = Color.lerp(_colorBegin, _colorEnd, t);

    _indentEnd = widget.indent;
    _endIndentEnd = widget.endIndent;
    _thicknessEnd = widget.thickness;
    _colorEnd = widget.color;

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fallbackColor = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final t = _animation.value;
        final indent = lerpDouble(_indentBegin, _indentEnd, t)!;
        final endIndent = lerpDouble(_endIndentBegin, _endIndentEnd, t)!;
        final thickness = lerpDouble(_thicknessBegin, _thicknessEnd, t)!;
        final color =
            Color.lerp(
              _colorBegin ?? fallbackColor,
              _colorEnd ?? fallbackColor,
              t,
            ) ??
            fallbackColor;

        return widget.vertical
            ? VerticalDivider(
                color: color,
                thickness: thickness,
                indent: indent,
                width: 1,
                endIndent: endIndent,
              )
            : Divider(
                color: color,
                thickness: thickness,
                indent: indent,
                height: 1,
                endIndent: endIndent,
              );
      },
    );
  }
}
