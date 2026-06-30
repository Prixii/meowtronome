import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.freezed.dart';

@freezed
sealed class SchedulerNote with _$SchedulerNote {
  const factory SchedulerNote({
    required SoundType soundType,
    required double timeValueMs,
  }) = _SchedulerNote;

  factory SchedulerNote.initial() =>
      SchedulerNote(soundType: SoundType.type1, timeValueMs: 1000);
}

@freezed
sealed class SchedulerState with _$SchedulerState {
  const factory SchedulerState({
    required RhythmPattern pattern,
    required List<List<SchedulerNote>> noteQueue,
    required int bpm,
    required bool isRunning,
  }) = _SchedulerState;

  factory SchedulerState.initial() => SchedulerState(
    pattern: RhythmPattern.initial(),
    noteQueue: [],
    bpm: 120,
    isRunning: false,
  );
}

@freezed
sealed class SchedulerRuntimeState with _$SchedulerRuntimeState {
  const factory SchedulerRuntimeState({
    required int currentBeatIndex,
    required int currentNoteIndex,
    required double expectedCumulativeTimeMs,
  }) = _SchedulerRuntimeState;

  factory SchedulerRuntimeState.initial() => SchedulerRuntimeState(
    currentBeatIndex: 0,
    currentNoteIndex: -1,
    expectedCumulativeTimeMs: 0,
  );
}
