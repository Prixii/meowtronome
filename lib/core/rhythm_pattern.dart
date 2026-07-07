import 'package:meowtronome/core/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'rhythm_pattern.freezed.dart';
part 'rhythm_pattern.g.dart';

@freezed
sealed class Note with _$Note {
  const factory Note({@Default(SoundType.type1) SoundType soundType}) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}

@freezed
sealed class Beat with _$Beat {
  const factory Beat({
    @Default([Note(), Note(), Note(), Note()]) List<Note> notes,
  }) = _Beat;

  factory Beat.fromJson(Map<String, dynamic> json) => _$BeatFromJson(json);
}

@freezed
sealed class RhythmPattern with _$RhythmPattern {
  const factory RhythmPattern({
    @Default('Unnamed Pattern') String name,
    @Default([Beat(), Beat(), Beat(), Beat()]) List<Beat> beats,
  }) = _RhythmPattern;

  factory RhythmPattern.fromJson(Map<String, dynamic> json) =>
      _$RhythmPatternFromJson(json);

  factory RhythmPattern.defaultPattern() => RhythmPattern(
    name: 'Default Pattern',
    beats: List.generate(4, (_) => Beat()),
  );
}

@freezed
sealed class MetronomeState with _$MetronomeState {
  const factory MetronomeState({
    @Default(120) int bpm,
    @Default(RhythmPattern()) RhythmPattern pattern,
    @Default({}) Map<SoundType, String> soundTypeMap,
  }) = _MetronomeState;

  factory MetronomeState.fromJson(Map<String, dynamic> json) =>
      _$MetronomeStateFromJson(json);
}
