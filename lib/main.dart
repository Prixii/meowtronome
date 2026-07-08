import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meowtronome/ui/splash/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(kDebugMode ? const StatefulMainApp() : const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SplashPage());
  }
}

class StatefulMainApp extends StatefulWidget {
  const StatefulMainApp({super.key});

  @override
  State<StatefulMainApp> createState() => _StatefulMainAppState();
}

class _StatefulMainAppState extends State<StatefulMainApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SplashPage());
  }

  @override
  void initState() {
    super.initState();
    startPrintWindowSize(context);
  }

  Future<void> startPrintWindowSize(BuildContext context) async {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final size = MediaQuery.of(context).size;
      debugPrint('Window size: (${size.width} * ${size.height})');
      startPrintWindowSize(context);
    });
  }
}
