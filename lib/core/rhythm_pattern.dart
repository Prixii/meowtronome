import 'package:meowtronome/core/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'rhythm_pattern.freezed.dart';
part 'rhythm_pattern.g.dart';

@freezed
sealed class Note with _$Note {
  const factory Note({required SoundType soundType}) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  factory Note.initial({SoundType soundType = SoundType.type1}) =>
      Note(soundType: soundType);
}

@freezed
sealed class Beat with _$Beat {
  const factory Beat({required List<Note> notes}) = _Beat;

  factory Beat.fromJson(Map<String, dynamic> json) => _$BeatFromJson(json);

  factory Beat.initial({int noteCount = 4}) =>
      Beat(notes: List.generate(noteCount, (_) => Note.initial()));
}

@freezed
sealed class RhythmPattern with _$RhythmPattern {
  const factory RhythmPattern({
    required String name,
    required List<Beat> beats,
  }) = _RhythmPattern;

  factory RhythmPattern.fromJson(Map<String, dynamic> json) =>
      _$RhythmPatternFromJson(json);

  factory RhythmPattern.initial() => RhythmPattern(
    name: 'Default Pattern',
    beats: List.generate(4, (_) => Beat.initial()),
  );
}

@freezed
sealed class MetronomeState with _$MetronomeState {
  const factory MetronomeState({required RhythmPattern pattern}) =
      _MetronomeState;

  factory MetronomeState.fromJson(Map<String, dynamic> json) =>
      _$MetronomeStateFromJson(json);

  factory MetronomeState.initial() =>
      MetronomeState(pattern: RhythmPattern.initial());
}
