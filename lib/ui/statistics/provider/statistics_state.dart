import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics_state.freezed.dart';
part 'statistics_state.g.dart';

@freezed
sealed class StatisticsState with _$StatisticsState {
  const factory StatisticsState({
    @Default(YearlyStatistics()) YearlyStatistics currentStatistics,
    @Default(YearlyStatistics()) YearlyStatistics statisticsDisplaying,
  }) = _StatisticsState;
}

@freezed
sealed class YearlyStatistics with _$YearlyStatistics {
  const factory YearlyStatistics({
    @Default([]) List<StatisticsRecord> records,
  }) = _YearlyStatistics;

  factory YearlyStatistics.fromJson(Map<String, dynamic> json) =>
      _$YearlyStatisticsFromJson(json);
}

@freezed
sealed class StatisticsRecord with _$StatisticsRecord {
  const factory StatisticsRecord({
    @Default(0) int bpm,
    @Default(0) int startTimestamp,
    @Default(0) int endTimestamp,
  }) = _StatisticsRecord;

  factory StatisticsRecord.fromJson(Map<String, dynamic> json) =>
      _$StatisticsRecordFromJson(json);
}
