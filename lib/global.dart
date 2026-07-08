import 'package:flutter/material.dart';
import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/ui/metronome/model.dart';

const iconButtonSize = 24.0;

final noteStyles = [
  NoteStyle(
    color: const Color.fromARGB(255, 255, 255, 255),
    soundType: SoundType.type4,
  ),
  NoteStyle(
    color: const Color.fromARGB(255, 201, 48, 191),
    soundType: SoundType.type1,
  ),
  NoteStyle(
    color: const Color.fromARGB(255, 45, 101, 186),
    soundType: SoundType.type2,
  ),
  NoteStyle(
    color: const Color.fromARGB(255, 255, 191, 0),
    soundType: SoundType.type3,
  ),
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
