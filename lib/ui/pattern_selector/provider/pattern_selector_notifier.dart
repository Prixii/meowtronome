import 'package:flutter/material.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/pattern_selector/provider/pattern_selector_state.dart';

class PatternSelectorNotifier extends ChangeNotifier {
  var _state = PatternSelectorState();

  PatternSelectorNotifier() {
    _state = _state.copyWith(
      systemPatterns: systemRhythmPatterns,
      userPatterns: {},
    );
  }

  Map<String, RhythmPattern> getPatterns() {
    Map<String, RhythmPattern> patterns = {};
    for (final pattern in _state.systemPatterns) {
      patterns[pattern.name] = pattern;
    }
    patterns.addAll(_state.userPatterns);
    return patterns;
  }
}
