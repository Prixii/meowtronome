import 'package:flutter/material.dart';
import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/gen/fonts.gen.dart';
import 'package:meowtronome/ui/metronome/model.dart';
import 'package:uuid/uuid.dart';

final repoUrl = 'https://github.com/Prixii/meowtronome';

class OptionData {
  final String label;
  final String value;

  const OptionData({required this.label, required this.value});
}

final uuid = Uuid();

final noteStyles = [
  NoteStyle(shape: NoteShape.circle, soundType: SoundType.type1),
  NoteStyle(shape: NoteShape.diamond, soundType: SoundType.type2),
  NoteStyle(shape: NoteShape.triangle, soundType: SoundType.type3),
  NoteStyle(shape: NoteShape.square, soundType: SoundType.type4),
];

final noteStyleMap = {for (final style in noteStyles) style.soundType: style};

final titleTextStyle = const TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  fontFamily: FontFamily.alimamaShuhei,
);

final subtitleTextStyle = const TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  fontFamily: FontFamily.alimamaShuhei,
);

final bodyTextStyle = const TextStyle(
  fontSize: 14,
  fontFamily: FontFamily.alimamaShuhei,
);

const defaultSoundMap = {
  SoundType.type1: 'assets/audio/drum_0.wav',
  SoundType.type2: 'assets/audio/drum_1.wav',
  SoundType.type3: 'assets/audio/drum_2.wav',
  SoundType.type4: 'assets/audio/drum_3.wav',
};

const systemRhythmPatterns = [
  RhythmPattern(
    name: '4/4',
    beats: [
      Beat(
        notes: [
          Note(soundType: SoundType.type3),
          Note(soundType: SoundType.type1),
          Note(soundType: SoundType.type1),
          Note(soundType: SoundType.type1),
        ],
      ),
      Beat(
        notes: [
          Note(soundType: SoundType.type2),
          Note(soundType: SoundType.type1),
          Note(soundType: SoundType.type1),
          Note(soundType: SoundType.type1),
        ],
      ),
      Beat(
        notes: [
          Note(soundType: SoundType.type2),
          Note(soundType: SoundType.type1),
          Note(soundType: SoundType.type1),
          Note(soundType: SoundType.type1),
        ],
      ),
      Beat(
        notes: [
          Note(soundType: SoundType.type2),
          Note(soundType: SoundType.type1),
          Note(soundType: SoundType.type1),
          Note(soundType: SoundType.type1),
        ],
      ),
    ],
  ),
  RhythmPattern(
    name: '3/4',
    beats: [
      Beat(
        notes: [
          Note(soundType: SoundType.type3),
          Note(soundType: SoundType.type1),
          Note(soundType: SoundType.type1),
        ],
      ),
      Beat(
        notes: [
          Note(soundType: SoundType.type2),
          Note(soundType: SoundType.type1),
          Note(soundType: SoundType.type1),
        ],
      ),
      Beat(
        notes: [
          Note(soundType: SoundType.type2),
          Note(soundType: SoundType.type1),
          Note(soundType: SoundType.type1),
        ],
      ),
    ],
  ),
];
