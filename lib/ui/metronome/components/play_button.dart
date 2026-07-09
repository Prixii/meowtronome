import 'package:flutter/material.dart';
import 'package:meowtronome/ui/layout_helper.dart';

class PlayButton extends StatefulWidget {
  const PlayButton({
    super.key,
    required this.isRunning,
    required this.onToggle,
  });
  final bool isRunning;
  final void Function() onToggle;
  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late ColorTween _foregroundColorTween;
  late ColorTween _backgroundColorTween;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(covariant PlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isRunning != widget.isRunning) {
      if (widget.isRunning) {
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
    _backgroundColorTween = ColorTween(
      begin: Theme.of(context).colorScheme.secondary,
      end: Theme.of(context).colorScheme.primary,
    );
    _foregroundColorTween = ColorTween(
      begin: Theme.of(context).colorScheme.primary,
      end: Theme.of(context).colorScheme.secondary,
    );

    return GestureDetector(
      onTap: () => widget.onToggle(),
      child: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final foregroundColor = _foregroundColorTween.evaluate(_animation);
            final backgroundColor = _backgroundColorTween.evaluate(_animation);
            return Container(
              width: .infinity,
              clipBehavior: .hardEdge,
              height: LayoutHelper.getPlayButtonHeight(context),
              decoration: BoxDecoration(color: backgroundColor),
              child: Stack(
                alignment: .center,
                children: [
                  Transform.translate(
                    offset: Offset(
                      0,
                      _animation.value *
                          LayoutHelper.getPlayButtonHeight(context),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      size: LayoutHelper.getPlayButtonHeight(context) * 0.8,
                      color: foregroundColor,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(
                      0,
                      (1 - _animation.value) *
                          LayoutHelper.getPlayButtonHeight(context),
                    ),
                    child: Icon(
                      Icons.pause,
                      size: LayoutHelper.getPlayButtonHeight(context) * 0.8,
                      color: foregroundColor,
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
}
