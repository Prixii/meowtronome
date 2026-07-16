import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/pattern_selector/provider/pattern_selector_state.dart';
import 'package:meowtronome/ui/shared_preferences_helper.dart';

class PatternSelectorNotifier extends ChangeNotifier {
  var _state = PatternSelectorState();

  PatternSelectorNotifier() {
    final raw = sharedPreferencesHelper.getJsonAndDecode<Map<String, dynamic>>(
      .userPatterns,
    );
    final userPatterns =
        raw?.map(
          (id, json) => MapEntry(
            id,
            RhythmPattern.fromJson(Map<String, dynamic>.from(json as Map)),
          ),
        ) ??
        {};
    _state = _state.copyWith(
      systemPatterns: systemRhythmPatterns,
      userPatterns: userPatterns,
    );
  }

  void addPattern(RhythmPattern pattern) {
    String patternUuid = uuid.v4();

    _state = _state.copyWith(
      userPatterns: {
        ..._state.userPatterns,
        patternUuid: pattern.copyWith(name: '新预设'),
      },
    );

    _saveUserPatterns();
    notifyListeners();
  }

  void renamePattern(String patternUuid, String newName) {
    _state = _state.copyWith(
      userPatterns: {
        ..._state.userPatterns,
        patternUuid: _state.userPatterns[patternUuid]!.copyWith(name: newName),
      },
    );
    _saveUserPatterns();
    notifyListeners();
  }

  void deletePattern(String patternUuid) {
    var newMap = {..._state.userPatterns};
    newMap.remove(patternUuid);

    _state = _state.copyWith(userPatterns: newMap);

    _saveUserPatterns();
    notifyListeners();
  }

  void _saveUserPatterns() {
    sharedPreferencesHelper.setString(
      .userPatterns,
      jsonEncode(
        _state.userPatterns.map(
          (id, pattern) => MapEntry(id, pattern.toJson()),
        ),
      ),
    );
  }

  Map<String, RhythmPattern> get userPatterns => _state.userPatterns;
  List<RhythmPattern> get systemPatterns => _state.systemPatterns;
}
