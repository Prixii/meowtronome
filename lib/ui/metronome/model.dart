import 'package:meowtronome/core/enums.dart';

enum NoteShape { square, circle, diamond, triangle }

class NoteStyle {
  const NoteStyle({
    required this.shape,
    this.filled = false,
    required this.soundType,
  });
  final NoteShape shape;
  final bool filled;
  final SoundType soundType;
}
