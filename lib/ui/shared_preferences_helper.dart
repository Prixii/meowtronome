import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesHelper = SharedPreferencesHelper();

class SharedPreferencesHelper {
  late final SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  dynamic getJsonAndDecode(String key) =>
      jsonDecode(prefs.getString(key) ?? '{}');

  void setString(String key, String value) => prefs.setString(key, value);
}
