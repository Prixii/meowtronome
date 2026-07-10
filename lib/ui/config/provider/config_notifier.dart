import 'package:flutter/material.dart';
import 'package:meowtronome/core/soloud/soloud_helper.dart';
import 'package:meowtronome/ui/config/provider/config_state.dart';

class ConfigNotifier extends ChangeNotifier {
  var _state = ConfigState();

  ConfigNotifier() {
    final globalVolume = soloudHelper.getGlobalVolume();

    _state = _state.copyWith(soloudGlobalVolume: globalVolume);
  }

  void setSoloudGlobalVolume(double volume) {
    _state = _state.copyWith(soloudGlobalVolume: volume);
    soloudHelper.setGlobalVolume(volume);
    notifyListeners();
  }

  double get soloudGlobalVolume => _state.soloudGlobalVolume;

  void setAutoCheckForUpdates(bool value) {
    _state = _state.copyWith(autoCheckForUpdates: value);
    notifyListeners();
  }

  bool get autoCheckForUpdates => _state.autoCheckForUpdates;
}
