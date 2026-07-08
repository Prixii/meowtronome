import 'package:flutter/material.dart';
import 'package:meowtronome/ui/metronome/components/bpm_panel.dart';
import 'package:meowtronome/ui/metronome/components/pattern_panel.dart';
import 'package:meowtronome/ui/metronome/components/play_button.dart';
import 'package:meowtronome/ui/metronome/components/top_button_group.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class MetronomeLayoutVertical extends StatelessWidget {
  const MetronomeLayoutVertical({super.key, required this.notifier});
  final MetronomeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopButtonGroup(notifier: notifier),
        const SizedBox(height: 32),
        BpmPanel(notifier: notifier),
        const SizedBox(height: 48),
        Expanded(child: PatternPanel(notifier: notifier)),
        const SizedBox(height: 64),
        PlayButton(notifier: notifier),
      ],
    );
  }
}
