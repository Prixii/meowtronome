import 'dart:async';

import 'package:flutter/material.dart';

class CustomIconButton extends StatefulWidget {
  const CustomIconButton({
    super.key,
    this.onTap,
    this.size = 24.0,
    required this.icon,
    this.enableLongPressRepeat = false,
    this.expand = false,
    this.padding = EdgeInsets.zero,
  });

  final void Function()? onTap;
  final double size;
  final IconData icon;
  final bool enableLongPressRepeat;
  final bool expand;
  final EdgeInsetsGeometry padding;

  static Size layoutSize({
    required double iconSize,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    final resolved = padding.resolve(TextDirection.ltr);
    return Size(iconSize + resolved.horizontal, iconSize + resolved.vertical);
  }

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton>
    with TickerProviderStateMixin {
  bool _isTapping = false;
  bool _isLongPressing = false;

  Timer? _timer;
  DateTime? _startTime;

  late final AnimationController _controller;
  late final Animation<double> _animation;

  final Duration initialInterval = const Duration(milliseconds: 300);
  final Duration minInterval = const Duration(milliseconds: 50);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canAnimate = widget.enableLongPressRepeat;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onTap?.call(),
      onTapDown: canAnimate ? (_) => _setIsTapping(true) : null,
      onTapCancel: canAnimate ? () => _setIsTapping(false) : null,
      onTapUp: canAnimate ? (_) => _setIsTapping(false) : null,
      onLongPress: canAnimate ? () => _startRepeat() : null,
      onLongPressUp: canAnimate ? () => _stopRepeat() : null,
      child: canAnimate
          ? AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return _buildContent(
                  backgroundColor: Color.lerp(
                    colorScheme.primaryContainer,
                    colorScheme.primary,
                    _animation.value,
                  )!,
                  iconColor: Color.lerp(
                    colorScheme.primary,
                    colorScheme.primaryContainer,
                    _animation.value,
                  )!,
                );
              },
            )
          : _buildContent(
              backgroundColor: colorScheme.primaryContainer,
              iconColor: colorScheme.primary,
            ),
    );
  }

  Widget _buildContent({
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      width: widget.expand ? double.infinity : null,
      height: widget.expand ? double.infinity : null,
      alignment: widget.expand ? Alignment.center : null,
      padding: widget.padding,
      decoration: BoxDecoration(color: backgroundColor),
      child: Icon(
        widget.icon,
        size: widget.size,
        color: iconColor,
      ),
    );
  }

  void _setIsTapping(bool value) {
    _isTapping = value;
    _updatePressedAnimation();
  }

  void _updatePressedAnimation() {
    if (_isTapping || _isLongPressing) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _startRepeat() {
    _startTime = DateTime.now();
    _isLongPressing = true;
    _updatePressedAnimation();
    void tick() {
      widget.onTap?.call();

      final elapsed = DateTime.now().difference(_startTime!).inMilliseconds;
      final intervalMs = (300 * (1 - elapsed / 3000)).clamp(50, 300).toInt();
      _timer = Timer(Duration(milliseconds: intervalMs), tick);
    }

    widget.onTap?.call();
    _timer = Timer(initialInterval, tick);
  }

  void _stopRepeat() {
    _isLongPressing = false;
    _updatePressedAnimation();
    _timer?.cancel();
    _timer = null;
    _startTime = null;
  }
}
