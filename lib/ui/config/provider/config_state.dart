import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meowtronome/ui/metronome/model.dart';

part 'config_state.freezed.dart';
part 'config_state.g.dart';

@freezed
sealed class ConfigState with _$ConfigState {
  const factory ConfigState({
    @Default(0.5) double soloudGlobalVolume,
    @Default(true) bool autoCheckForUpdates,
    @Default(false) bool wakelockEnabled,
    @Default(false) bool playInBackground,
    @Default(AntiBluetoothAutoStandbyMode.disable)
    AntiBluetoothAutoStandbyMode antiBluetoothAutoStandby,
    @Default(60) int antiBluetoothAutoStandbyBelowBpm,
  }) = _ConfigState;

  factory ConfigState.fromJson(Map<String, dynamic> json) =>
      _$ConfigStateFromJson(json);
}
