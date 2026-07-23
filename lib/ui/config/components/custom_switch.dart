import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  static const double width = 56;
  static const double height = 28;

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

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

    if (widget.value) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: SizedBox(
        width: CustomSwitch.width,
        height: CustomSwitch.height,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.primary, width: 2),
                color: widget.value
                    ? colorScheme.primary
                    : colorScheme.primaryFixed,
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    left: _thumbOffset(_animation.value),
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: CustomSwitch.height,
                      color: colorScheme.primaryContainer,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  double _thumbOffset(double progress) {
    const thumbSize = CustomSwitch.height;
    return progress * (CustomSwitch.width - thumbSize);
  }
}
