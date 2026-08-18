import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meowtronome/ui/metronome/model.dart';

final lightTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Color(0xFF3F1309),
    primaryFixedDim: Color(0xFF635951),
    secondary: Color(0xFF574935),
    primaryFixed: Color(0xFFBDB097),
    primaryContainer: Color(0xFFE9D7Bc),
  ),
);

final darkTheme = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: Color(0xFFE9D7BC),
    primaryFixedDim: Color(0xFFA89880),
    secondary: Color(0xFFC4B49A),
    primaryFixed: Color(0xFF5C4A3A),
    primaryContainer: Color(0xFF2A1810),
  ),
);

ThemeMode themeModeOf(AppThemeMode mode) => switch (mode) {
  AppThemeMode.light => ThemeMode.light,
  AppThemeMode.dark => ThemeMode.dark,
  AppThemeMode.system => ThemeMode.system,
};

bool get isDesktopPlatform =>
    !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

/// Desktop: [active] → primary, otherwise [inactive] (default secondary).
/// Mobile: always primary.
Color resolveInteractiveColor(
  BuildContext context, {
  required bool active,
  Color? inactive,
}) {
  final scheme = Theme.of(context).colorScheme;
  if (!isDesktopPlatform) {
    return scheme.primary;
  }
  return active ? scheme.primary : (inactive ?? scheme.secondary);
}
