import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meowtronome/core/soloud/soloud_helper.dart';
import 'package:meowtronome/ui/config/provider/config_state.dart';
import 'package:meowtronome/ui/shared_preferences_helper.dart';

ConfigState loadConfigState() {
  final json = sharedPreferencesHelper.getJsonAndDecode<Map<String, dynamic>>(
    SharedPreferencesKeys.configState,
  );
  return json == null ? const ConfigState() : ConfigState.fromJson(json);
}

class ConfigNotifier extends ChangeNotifier {
  ConfigNotifier() : _state = loadConfigState() {
    soloudHelper.setGlobalVolume(_state.soloudGlobalVolume);
  }

  ConfigState _state;

  void setSoloudGlobalVolume(double volume) {
    _state = _state.copyWith(soloudGlobalVolume: volume);
    soloudHelper.setGlobalVolume(volume);
    saveConfigState(_state);
    notifyListeners();
  }

  double get soloudGlobalVolume => _state.soloudGlobalVolume;

  void setAutoCheckForUpdates(bool value) {
    _state = _state.copyWith(autoCheckForUpdates: value);
    saveConfigState(_state);
    notifyListeners();
  }

  void saveConfigState(ConfigState state) {
    sharedPreferencesHelper.setString(
      SharedPreferencesKeys.configState,
      jsonEncode(state.toJson()),
    );
  }

  bool get autoCheckForUpdates => _state.autoCheckForUpdates;
}
