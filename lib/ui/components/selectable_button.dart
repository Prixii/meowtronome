import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';

class SelectableButton extends StatefulWidget {
  const SelectableButton({
    super.key,
    required this.selected,
    this.text,
    this.onTap,
    this.icon,
    this.size = 24.0,
  });

  final void Function()? onTap;
  final IconData? icon;
  final bool selected;
  final double size;
  final String? text;

  @override
  State<SelectableButton> createState() => _SelectableButtonState();
}

class _SelectableButtonState extends State<SelectableButton>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _clipAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _clipAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOut,
    );

    if (widget.selected) {
      _controller.forward(from: 1);
    }
  }

  @override
  void didUpdateWidget(covariant SelectableButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selected != widget.selected) {
      if (widget.selected) {
        _controller.forward(from: 0);
      } else {
        _controller.reverse(from: 1.0);
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
    return LayoutBuilder(
      builder: (_, constraints) => GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          children: [
            Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Center(
                child: (widget.icon != null)
                    ? Icon(
                        widget.icon,
                        size: widget.size,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : Text(
                        widget.text ?? '',
                        style: bodyTextStyle.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
              ),
            ),
            AnimatedBuilder(
              animation: _clipAnimation,
              builder: (_, child) => ClipRect(
                clipper: RevealClipper(_clipAnimation.value),
                child: child,
              ),
              child: Container(
                color: Theme.of(context).colorScheme.primary,
                child: Center(
                  child: (widget.icon != null)
                      ? Icon(
                          widget.icon,
                          size: widget.size,
                          color: Theme.of(context).colorScheme.primaryContainer,
                        )
                      : Text(
                          widget.text ?? '',
                          style: bodyTextStyle.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevealClipper extends CustomClipper<Rect> {
  RevealClipper(this.progress);

  final double progress;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, size.height * (1 - progress), size.width, size.height);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) =>
      progress != (oldClipper as RevealClipper).progress;
}
