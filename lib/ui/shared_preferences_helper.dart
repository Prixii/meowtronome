import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesHelper = SharedPreferencesHelper();

enum SharedPreferencesKeys { metronomeState, userPatterns, configState }

class SharedPreferencesHelper {
  late final SharedPreferences prefs;

  static const keys = {};

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  T? getJsonAndDecode<T>(SharedPreferencesKeys key) {
    final rawJson = prefs.getString(key.name);
    if (rawJson == null || rawJson.isEmpty) return null;
    return jsonDecode(rawJson) as T;
  }

  void setString(SharedPreferencesKeys key, String value) =>
      prefs.setString(key.name, value);
}
