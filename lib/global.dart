import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/ui/metronome/model.dart';

SDF circleSDF(double r) {
  return (Offset p) {
    return p.distance - r;
  };
}

SDF squareSDF(double r) {
  return (Offset p) {
    final q = Offset(p.dx.abs() - r, p.dy.abs() - r);

    final outside = Offset(max(q.dx, 0), max(q.dy, 0));

    return outside.distance + min(max(q.dx, q.dy), 0);
  };
}

// here r is half of the diagonal
SDF diamondSDF(double r) {
  return (Offset p) {
    final dist = (p.dx.abs() + p.dy.abs() - r) / sqrt(2);

    return dist;
  };
}

// here r is the outer radius
SDF triangleSDF(double r) {
  return (Offset p) {
    final y = -p.dy;

    final d1 = y - r / 2;
    final d2 = (sqrt(3) * p.dx + y - r) / 2;
    final d3 = (-sqrt(3) * p.dx + y - r) / 2;

    return max(d1, max(d2, d3));
  };
}

final noteStyles = [
  NoteStyle(
    color: Colors.white,
    pressedColor: Colors.grey,
    soundType: SoundType.none,
    size: 16,
  ),
  NoteStyle(
    color: Colors.red,
    pressedColor: Colors.pink,
    soundType: SoundType.type1,
    size: 16,
  ),
  NoteStyle(
    color: Colors.green,
    pressedColor: Colors.lightGreen,
    soundType: SoundType.type2,
    size: 16,
  ),
  NoteStyle(
    color: Colors.blue,
    pressedColor: Colors.lightBlue,
    soundType: SoundType.type3,
    size: 16,
  ),
];

final noteStyleMap = {for (final style in noteStyles) style.soundType: style};
