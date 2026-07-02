import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/core/enums.dart';

class AnimatedNote extends StatefulWidget {
  const AnimatedNote({
    super.key,
    required this.soundType,
    required this.isPlaying,
  });

  final SoundType soundType;
  final bool isPlaying;

  static const double paddingSize = 4;

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
      TweenSequenceItem(tween: Tween(begin: 1, end: 0.9), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.2), weight: 3),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1), weight: 5),
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

    return SizedBox(
      width: style.size + AnimatedNote.paddingSize * 2,
      height: style.size + AnimatedNote.paddingSize * 2,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: style.size,
          height: style.size,
          decoration: BoxDecoration(
            color: style.filled ? style.color : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: style.color, width: style.strokeWidth),
          ),
        ),
      ),
    );
  }
}
