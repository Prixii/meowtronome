import 'package:freezed_annotation/freezed_annotation.dart';

part 'metronome_runtime_state.freezed.dart';

@freezed
sealed class MetronomeRuntimeState with _$MetronomeRuntimeState {
  const factory MetronomeRuntimeState({@Default(-1) int selectedTopTabIndex}) =
      _MetronomeRuntimeState;
}

@freezed
sealed class PlayPosition with _$PlayPosition {
  const PlayPosition._();

  const factory PlayPosition({
    @Default(-1) int beatIndex,
    @Default(-1) int noteIndex,
  }) = _PlayPosition;

  bool matches(int beatIndex, int noteIndex) =>
      this.beatIndex == beatIndex && this.noteIndex == noteIndex;
}
