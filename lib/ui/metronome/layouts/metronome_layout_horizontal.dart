import 'package:flutter/material.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
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
              const CustomDivider(),
              Expanded(child: BpmPanel(notifier: notifier)),
              const CustomDivider(),
              PlayButton(notifier: notifier),
            ],
          ),
        ),
        const CustomDivider(vertical: true),
        Expanded(
          child: Column(
            children: [Expanded(child: PatternPanel(notifier: notifier))],
          ),
        ),
      ],
    );
  }
}
