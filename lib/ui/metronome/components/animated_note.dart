import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/model.dart';

class AnimatedNote extends StatefulWidget {
  const AnimatedNote({
    super.key,
    required this.soundType,
    required this.isPlaying,
    required this.size,
    this.strokeWidth,
    this.color,
  });

  final SoundType soundType;
  final bool isPlaying;
  final double size;
  final double? strokeWidth;
  final Color? color;

  static const double paddingSize = 4;
  static const maxSizeScale = 1.4;
  static const minSizeScale = 0.9;

  static Size layoutSize(BuildContext context, {double? size}) {
    final noteSize = size ?? LayoutHelper.getNoteSize(context);
    final dimension = noteSize + paddingSize * 2;
    return Size(dimension, dimension);
  }

  @override
  State<AnimatedNote> createState() => _AnimatedNoteState();
}

class _AnimatedNoteState extends State<AnimatedNote>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1, end: AnimatedNote.minSizeScale),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: AnimatedNote.minSizeScale,
          end: AnimatedNote.maxSizeScale,
        ),
        weight: 3,
      ),
      TweenSequenceItem(
        tween: Tween(begin: AnimatedNote.maxSizeScale, end: 1),
        weight: 5,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant AnimatedNote oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isPlaying && widget.isPlaying) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = noteStyleMap[widget.soundType]!;
    final layoutSize = AnimatedNote.layoutSize(context, size: widget.size);
    final size = widget.size;
    final strokeWidth =
        widget.strokeWidth ?? LayoutHelper.getNoteStrokeWidth(context);

    return SizedBox(
      width: layoutSize.width,
      height: layoutSize.height,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: CustomPaint(
          size: Size(size, size),
          painter: _NoteShapePainter(
            shape: style.shape,
            color: widget.color ?? Theme.of(context).colorScheme.primary,
            strokeWidth: strokeWidth,
            filled: style.filled,
          ),
        ),
      ),
    );
  }
}

class _NoteShapePainter extends CustomPainter {
  const _NoteShapePainter({
    required this.shape,
    required this.color,
    required this.strokeWidth,
    required this.filled,
  });

  final NoteShape shape;
  final Color color;
  final double strokeWidth;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final inset = strokeWidth / 2;
    final drawRect = Rect.fromLTWH(
      inset,
      inset,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    switch (shape) {
      case NoteShape.square:
        canvas.drawRect(drawRect, paint);
      case NoteShape.circle:
        canvas.drawCircle(drawRect.center, drawRect.shortestSide / 2, paint);
      case NoteShape.diamond:
        canvas.drawPath(_diamondPath(drawRect), paint);
      case NoteShape.triangle:
        canvas.drawPath(_trianglePath(drawRect), paint);
    }
  }

  Path _diamondPath(Rect rect) {
    final center = rect.center;
    return Path()
      ..moveTo(center.dx, rect.top)
      ..lineTo(rect.right, center.dy)
      ..lineTo(center.dx, rect.bottom)
      ..lineTo(rect.left, center.dy)
      ..close();
  }

  Path _trianglePath(Rect rect) {
    final side = rect.shortestSide;
    final height = side * sqrt(3) / 2;
    final left = rect.left + (rect.width - side) / 2;
    final top = rect.top + (rect.height - height) / 2;

    return Path()
      ..moveTo(left + side / 2, top)
      ..lineTo(left + side, top + height)
      ..lineTo(left, top + height)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _NoteShapePainter oldDelegate) {
    return shape != oldDelegate.shape ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        filled != oldDelegate.filled;
  }
}
