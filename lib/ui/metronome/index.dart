import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meowtronome/ui/config/index.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWide = screenWidth > screenHeight;
    final ratio =
        min(screenHeight, screenWidth) / max(screenHeight, screenWidth);
    final shouldSquare = ratio > 0.6;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: LayoutHelper.getAppPadding(context),
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
      ),
    );
  }
}
