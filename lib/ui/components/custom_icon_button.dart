import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';

class CustomIconButton extends StatefulWidget {
  const CustomIconButton({
    super.key,
    this.onTap,
    this.size = iconButtonSize,
    this.color = Colors.black,
    this.activeColor = Colors.red,
    required this.icon,
    this.padding = const EdgeInsets.all(16),
    this.alwaysShowBackground = true,
  });

  final void Function()? onTap;
  final double size;
  final Color color;
  final Color activeColor;
  final IconData icon;
  final EdgeInsetsGeometry padding;
  final bool alwaysShowBackground;

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  bool _isTapping = false;
  bool _isLongPressing = false;

  Timer? _timer;
  DateTime? _startTime;

  final Duration initialInterval = const Duration(milliseconds: 300);
  final Duration minInterval = const Duration(milliseconds: 50);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onTap?.call(),
      onTapDown: (_) => setState(() => _isTapping = true),
      onTapCancel: () => setState(() => _isTapping = false),
      onTapUp: (_) => setState(() => _isTapping = false),
      onLongPress: () => _startRepeat(),
      onLongPressUp: () => _stopRepeat(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.padding.horizontal),
          color: widget.alwaysShowBackground
              ? ((_isTapping || _isLongPressing)
                    ? widget.activeColor
                    : Colors.grey[100])
              : Colors.transparent,
        ),
        child: Padding(
          padding: widget.padding,
          child: Icon(
            widget.icon,
            size: widget.size,
            color: (_isTapping || _isLongPressing)
                ? widget.activeColor
                : widget.color,
          ),
        ),
      ),
    );
  }

  void _startRepeat() {
    _startTime = DateTime.now();
    setState(() => _isLongPressing = true);

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
    setState(() => _isLongPressing = false);
    _timer?.cancel();
    _timer = null;
    _startTime = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
