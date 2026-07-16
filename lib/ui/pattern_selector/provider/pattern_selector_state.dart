import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';

part 'pattern_selector_state.freezed.dart';

@freezed
sealed class PatternSelectorState with _$PatternSelectorState {
  const factory PatternSelectorState({
    @Default([]) List<RhythmPattern> systemPatterns,
    @Default({}) Map<String, RhythmPattern> userPatterns,
  }) = _PatternSelectorState;
}
