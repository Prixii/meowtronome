import 'package:flutter/material.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/layouts/metronome_layout_horizontal.dart';
import 'package:meowtronome/ui/metronome/layouts/metronome_layout_square.dart';
import 'package:meowtronome/ui/metronome/layouts/metronome_layout_vertical.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';
import 'package:provider/provider.dart';

class MetronomePage extends StatelessWidget {
  const MetronomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MetronomeNotifier>();
    final layoutMode = LayoutHelper.getLayoutMode(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        child: Center(
          child: layoutMode == LayoutMode.square
              ? MetronomeLayoutSquare(notifier: notifier)
              : layoutMode == LayoutMode.vertical
              ? MetronomeLayoutVertical(notifier: notifier)
              : MetronomeLayoutHorizontal(notifier: notifier),
        ),
      ),
    );
  }
}
