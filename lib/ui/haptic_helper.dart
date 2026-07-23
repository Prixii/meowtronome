import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

bool get supportsHaptics =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

Future<void> triggerLightHaptic() async {
  if (!supportsHaptics) return;
  await HapticFeedback.lightImpact();
}
