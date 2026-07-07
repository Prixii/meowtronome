import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.freezed.dart';

@freezed
sealed class SchedulerNote with _$SchedulerNote {
  const factory SchedulerNote({
    @Default(SoundType.type1) SoundType soundType,
    @Default(1000) double timeValueMs,
  }) = _SchedulerNote;
}

@freezed
sealed class SchedulerState with _$SchedulerState {
  const factory SchedulerState({
    @Default(RhythmPattern()) RhythmPattern pattern,
    @Default([]) List<List<SchedulerNote>> noteQueue,
    @Default(120) int bpm,
    @Default(false) bool isRunning,
  }) = _SchedulerState;
}

@freezed
sealed class SchedulerRuntimeState with _$SchedulerRuntimeState {
  const factory SchedulerRuntimeState({
    @Default(0) int currentBeatIndex,
    @Default(-1) int currentNoteIndex,
    @Default(0) double expectedCumulativeTimeMs,
  }) = _SchedulerRuntimeState;
}
