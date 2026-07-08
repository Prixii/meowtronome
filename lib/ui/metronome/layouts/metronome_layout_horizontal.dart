import 'package:flutter/material.dart';
import 'package:meowtronome/ui/metronome/components/bpm_panel.dart';
import 'package:meowtronome/ui/metronome/components/pattern_panel.dart';
import 'package:meowtronome/ui/metronome/components/play_button.dart';
import 'package:meowtronome/ui/metronome/components/top_button_group.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class MetronomeLayoutHorizontal extends StatelessWidget {
  const MetronomeLayoutHorizontal({super.key, required this.notifier});
  final MetronomeNotifier notifier;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              TopButtonGroup(notifier: notifier),
              const SizedBox(height: 32),
              Expanded(child: BpmPanel(notifier: notifier)),
              const SizedBox(height: 16),
              PlayButton(notifier: notifier),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            children: [Expanded(child: PatternPanel(notifier: notifier))],
          ),
        ),
      ],
    );
  }
}
