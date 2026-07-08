import 'package:flutter/material.dart';

/// AnimatedExpandRRect
/// from a circle to a rectangle
class AnimatedExpandRRect extends StatefulWidget {
  const AnimatedExpandRRect({
    super.key,
    required this.child,
    required this.beginRect,
    required this.endRect,
    this.beginBorderRadius,
    this.endBorderRadius = BorderRadius.zero,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
    this.controller,
    this.scaleChild = true,
  });

  final Widget child;

  final Rect beginRect;
  final Rect endRect;

  final BorderRadius? beginBorderRadius;
  final BorderRadius endBorderRadius;

  final Duration duration;
  final Curve curve;
  final AnimationController? controller;

  final bool scaleChild;

  @override
  State<AnimatedExpandRRect> createState() => _AnimatedExpandRRectState();
}

class _AnimatedExpandRRectState extends State<AnimatedExpandRRect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final bool _ownsController;

  late RectTween _rectTween;
  late BorderRadiusTween _radiusTween;

  @override
  void initState() {
    super.initState();

    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        AnimationController(vsync: this, duration: widget.duration);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
      reverseCurve: widget.curve.flipped,
    );

    _rectTween = RectTween(begin: widget.beginRect, end: widget.endRect);
    _radiusTween = BorderRadiusTween(
      begin: widget.beginBorderRadius ?? BorderRadius.zero,
      end: widget.endBorderRadius,
    );

    if (_ownsController) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Widget _buildChild(Rect rect, Widget child) {
    if (!widget.scaleChild) {
      return child;
    }

    final scaleX = rect.width / widget.endRect.width;
    final scaleY = rect.height / widget.endRect.height;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(scaleX, scaleY, 1),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final rect = _rectTween.evaluate(_animation)!;
        if (rect.width < 1 && rect.height < 1) {
          return const SizedBox.shrink();
        }
        final radius = _radiusTween.evaluate(_animation)!;
        return Positioned(
          left: rect.left,
          top: rect.top,
          width: rect.width,
          height: rect.height,
          child: ClipRRect(
            borderRadius: radius,
            clipBehavior: .hardEdge,
            child: _buildChild(rect, child!),
          ),
        );
      },
      child: SizedBox(
        width: widget.endRect.width,
        height: widget.endRect.height,
        child: widget.child,
      ),
    );
  }
}
