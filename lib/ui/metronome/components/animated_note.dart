import 'package:flutter/material.dart';
import 'package:meowtronome/constants.dart';
import 'package:meowtronome/core/enums.dart';

class AnimatedNote extends StatelessWidget {
  const AnimatedNote({super.key, required this.soundType});

  final SoundType soundType;

  @override
  Widget build(BuildContext context) {
    final style = noteStyleMap[soundType]!;
    return Container(
      width: style.size.toDouble(),
      height: style.size.toDouble(),
      decoration: BoxDecoration(
        color: style.filled ? style.color : Colors.transparent,
        borderRadius: BorderRadius.circular(style.size.toDouble() / 2),
        border: Border.all(
          color: style.color,
          width: style.strokeWidth.toDouble(),
        ),
      ),
    );
  }
}
