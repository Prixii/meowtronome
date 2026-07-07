import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meowtronome/ui/splash/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    startListenWindowSize(context);
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SplashPage());
  }

  Future<void> startListenWindowSize(BuildContext context) async {
    Timer(Duration(seconds: 1), () {
      final size = MediaQuery.sizeOf(context);
      debugPrint('CurrentSize: (${size.width}, ${size.height})');
      startListenWindowSize(context);
    });
  }
}
