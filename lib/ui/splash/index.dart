import 'package:flutter/material.dart';
import 'package:meowtronome/provider/metronome_notifier.dart';
import 'package:meowtronome/ui/metronome/index.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    init(context);
    return Scaffold(body: Center(child: FlutterLogo()));
  }

  Future<void> init(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => MetronomeNotifier(),
            child: const MetronomePage(),
          ),
        ),
      );
    }
  }
}
