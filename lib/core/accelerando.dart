import 'package:freezed_annotation/freezed_annotation.dart';

part 'accelerando.freezed.dart';
part 'accelerando.g.dart';

@freezed
sealed class AccelerandoConfig with _$AccelerandoConfig {
  const factory AccelerandoConfig({
    @Default(false) bool enabled,
    @Default(80) int startBpm,
    @Default(160) int endBpm,
    @Default(1) int barsPerStep,
    @Default(5) int bpmStep,
  }) = _AccelerandoConfig;

  factory AccelerandoConfig.fromJson(Map<String, dynamic> json) =>
      _$AccelerandoConfigFromJson(json);
}
