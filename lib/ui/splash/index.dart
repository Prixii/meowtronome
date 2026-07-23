import 'package:flutter/material.dart';
import 'package:meowtronome/core/soloud/soloud_helper.dart';
import 'package:meowtronome/gen/assets.gen.dart';
import 'package:meowtronome/ui/color_helper.dart';
import 'package:meowtronome/ui/config/provider/config_notifier.dart';
import 'package:meowtronome/ui/metronome/index.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';
import 'package:meowtronome/ui/shared_preferences_helper.dart';
import 'package:meowtronome/ui/statistics/provider/statistics_notifier.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final MetronomeNotifier _provider = MetronomeNotifier();
  late final StatisticsNotifier _statistics = StatisticsNotifier();
  ConfigNotifier? _config;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _provider.attachStatistics(_statistics);
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      _initComponents(),
      Future.delayed(const Duration(seconds: 1)),
    ]);

    if (!mounted) return;
    setState(() => _ready = true);
  }

  Future<void> _initComponents() async {
    await sharedPreferencesHelper.init();
    await Future.wait([
      _provider.init(),
      _statistics.init(),
      soloudHelper.init(),
    ]);
    _config = ConfigNotifier();
  }

  @override
  void dispose() {
    _provider.dispose();
    _statistics.dispose();
    _config?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      theme: lightTheme,
      home: _ready ? const MetronomePage() : const _SplashBody(),
    );

    final config = _config;
    if (config == null) return app;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _provider),
        ChangeNotifierProvider.value(value: _statistics),
        ChangeNotifierProvider.value(value: config),
      ],
      child: app,
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody();

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
