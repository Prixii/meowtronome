import 'package:flutter/material.dart';
import 'package:meowtronome/core/soloud/soloud_helper.dart';
import 'package:meowtronome/gen/assets.gen.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';
import 'package:meowtronome/ui/metronome/index.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  MetronomeNotifier? _provider;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final provider = MetronomeNotifier();
    _provider = provider;

    await Future.wait([
      soloudHelper.initialize(),
      provider.init(),
      Future.delayed(const Duration(seconds: 1)),
    ]);

    if (!mounted || _navigated) return;

    _navigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: const MetronomePage(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (!_navigated) {
      _provider?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircleAvatar(
          backgroundImage: Assets.image.icon.provider(),
          radius: 96,
        ),
      ),
    );
  }
}
