import 'package:flutter/material.dart';
import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/ui/metronome/model.dart';

final noteStyles = [
  NoteStyle(shape: NoteShape.square, soundType: SoundType.type4),
  NoteStyle(shape: NoteShape.circle, soundType: SoundType.type1),
  NoteStyle(shape: NoteShape.diamond, soundType: SoundType.type2),
  NoteStyle(shape: NoteShape.triangle, soundType: SoundType.type3),
];

final noteStyleMap = {for (final style in noteStyles) style.soundType: style};

final titleTextStyle = const TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
);

final subtitleTextStyle = const TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

final bodyTextStyle = const TextStyle(fontSize: 20);

const defaultSoundMap = {
  SoundType.type1: 'assets/audio/drum_0.wav',
  SoundType.type2: 'assets/audio/drum_1.wav',
  SoundType.type3: 'assets/audio/drum_2.wav',
  SoundType.type4: 'assets/audio/drum_3.wav',
};
