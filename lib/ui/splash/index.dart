import 'package:flutter/material.dart';
import 'package:meowtronome/core/soloud/soloud_helper.dart';
import 'package:meowtronome/gen/assets.gen.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';
import 'package:meowtronome/ui/metronome/index.dart';
import 'package:meowtronome/ui/shared_preferences_helper.dart';
import 'package:meowtronome/ui/statistics/provider/statistics_notifier.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late MetronomeNotifier _provider;
  late StatisticsNotifier _statistics;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _provider = MetronomeNotifier();
    _statistics = StatisticsNotifier();
    _provider.attachStatistics(_statistics);

    await Future.wait([
      initComponents(),
      Future.delayed(const Duration(seconds: 1)),
    ]);

    if (!mounted || _navigated) return;

    _navigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _provider),
            ChangeNotifierProvider.value(value: _statistics),
          ],
          child: const MetronomePage(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (!_navigated) {
      _provider.dispose();
      _statistics.dispose();
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

  Future<void> initComponents() async {
    await sharedPreferencesHelper.init();
    await Future.wait([
      _provider.init(),
      _statistics.init(),
      soloudHelper.init(),
    ]);
  }
}
