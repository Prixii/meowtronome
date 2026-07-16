import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meowtronome/core/audio/audio_background.dart';
import 'package:meowtronome/ui/color_helper.dart';
import 'package:meowtronome/ui/splash/index.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) await initializeDesktop();
  await initAudioBackground();
  runApp(kDebugMode ? const StatefulMainApp() : const MainApp());
}

Future<void> initializeDesktop() async {
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(const WindowOptions(), () async {
    await windowManager.setMinimumSize(const Size(400, 400));
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashPage(), theme: lightTheme);
  }
}

class StatefulMainApp extends StatefulWidget {
  const StatefulMainApp({super.key});

  @override
  State<StatefulMainApp> createState() => _StatefulMainAppState();
}

class _StatefulMainAppState extends State<StatefulMainApp> {
  Timer? _windowSizeTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _startPrintWindowSize(),
    );
  }

  void _startPrintWindowSize() {
    if (!mounted || _windowSizeTimer != null) return;

    _windowSizeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final view = View.of(context);
      final size = view.physicalSize / view.devicePixelRatio;
      debugPrint('Window size: (${size.width} * ${size.height})');
    });
  }

  @override
  void dispose() {
    _windowSizeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashPage(), theme: lightTheme);
  }
}
