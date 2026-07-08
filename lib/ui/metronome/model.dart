import 'package:flutter/material.dart';
import 'package:meowtronome/core/enums.dart';

typedef SDF = double Function(Offset point);

class NoteStyle {
  const NoteStyle({
    required this.color,
    required this.pressedColor,
    this.filled = false,
    required this.soundType,
  });
  final Color color;
  final Color pressedColor;
  final bool filled;
  final SoundType soundType;
}
