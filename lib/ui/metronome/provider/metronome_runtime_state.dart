import 'package:freezed_annotation/freezed_annotation.dart';

part 'metronome_runtime_state.freezed.dart';

@freezed
sealed class MetronomeRuntimeState with _$MetronomeRuntimeState {
  const factory MetronomeRuntimeState({@Default(-1) int selectedTopTabIndex}) =
      _MetronomeRuntimeState;
}
