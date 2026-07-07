import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meowtronome/ui/config/index.dart';
import 'package:meowtronome/ui/metronome/components/bpm_panel.dart';
import 'package:meowtronome/ui/metronome/components/pattern_panel.dart';
import 'package:meowtronome/ui/metronome/components/play_button.dart';
import 'package:meowtronome/ui/metronome/components/top_button_group.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWide = screenWidth > screenHeight;
    final ratio =
        min(screenHeight, screenWidth) / max(screenHeight, screenWidth);
    final shouldSquare = ratio > 0.6;
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: shouldSquare
                  ? MetronomeLayoutSquare(notifier: notifier)
                  : (isWide
                        ? MetronomeLayoutHorizontal(notifier: notifier)
                        : MetronomeLayoutVertical(notifier: notifier)),
            ),
          ),
          ConfigPage(
            onClose: () => notifier.closeConfigPage(),
            show: notifier.isConfigPageOpen,
            isWide: isWide,
          ),
        ],
      ),
    );
  }
}
