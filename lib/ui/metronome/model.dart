import 'package:flutter/material.dart';
import 'package:meowtronome/core/enums.dart';

typedef SDF = double Function(Offset point);

class NoteStyle {
  const NoteStyle({
    required this.color,
    required this.pressedColor,
    required this.size,
    this.filled = false,
    this.strokeWidth = 2,
    required this.soundType,
  });
  final Color color;
  final Color pressedColor;
  final int size;
  final bool filled;
  final int strokeWidth;
  final SoundType soundType;
}
