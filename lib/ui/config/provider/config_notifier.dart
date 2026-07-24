import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meowtronome/core/audio/audio_background.dart';
import 'package:meowtronome/core/soloud/soloud_helper.dart';
import 'package:meowtronome/ui/config/provider/config_state.dart';
import 'package:meowtronome/ui/shared_preferences_helper.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

ConfigState loadConfigState() {
  final json = sharedPreferencesHelper.getJsonAndDecode<Map<String, dynamic>>(
    SharedPreferencesKeys.configState,
  );
  return json == null ? const ConfigState() : ConfigState.fromJson(json);
}

class ConfigNotifier extends ChangeNotifier {
  ConfigNotifier() : _state = loadConfigState() {
    soloudHelper.setGlobalVolume(_state.soloudGlobalVolume);
    WakelockPlus.toggle(enable: _state.wakelockEnabled);
    setBackgroundPlaybackEnabled(_state.playInBackground);
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

  bool get autoCheckForUpdates => _state.autoCheckForUpdates;

  void setWakelockEnabled(bool value) {
    _state = _state.copyWith(wakelockEnabled: value);
    WakelockPlus.toggle(enable: value);
    saveConfigState(_state);
    notifyListeners();
  }

  bool get wakelockEnabled => _state.wakelockEnabled;

  void setPlayInBackground(bool value) {
    _state = _state.copyWith(playInBackground: value);
    unawaited(applyBackgroundPlaybackEnabled(value));
    saveConfigState(_state);
    notifyListeners();
  }

  bool get playInBackground => _state.playInBackground;

  void saveConfigState(ConfigState state) {
    sharedPreferencesHelper.setString(
      SharedPreferencesKeys.configState,
      jsonEncode(state.toJson()),
    );
  }
}
