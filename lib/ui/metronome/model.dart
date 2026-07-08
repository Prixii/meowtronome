import 'package:flutter/material.dart';
import 'package:meowtronome/core/enums.dart';

class NoteStyle {
  const NoteStyle({
    required this.color,
    this.filled = false,
    required this.soundType,
  });
  final Color color;
  final bool filled;
  final SoundType soundType;
}
