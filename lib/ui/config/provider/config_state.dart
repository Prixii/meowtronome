import 'package:freezed_annotation/freezed_annotation.dart';

part 'config_state.freezed.dart';
part 'config_state.g.dart';

@freezed
sealed class ConfigState with _$ConfigState {
  const factory ConfigState({
    @Default(0.5) double soloudGlobalVolume,
    @Default(true) bool autoCheckForUpdates,
  }) = _ConfigState;

  factory ConfigState.fromJson(Map<String, dynamic> json) =>
      _$ConfigStateFromJson(json);
}
