import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/metronome/components/bpm_panel.dart';
import 'package:meowtronome/ui/metronome/components/pattern_panel.dart';
import 'package:meowtronome/ui/metronome/components/play_button.dart';
import 'package:meowtronome/ui/metronome/components/top_button_group.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class MetronomeLayoutSquare extends StatefulWidget {
  const MetronomeLayoutSquare({super.key, required this.notifier});
  final MetronomeNotifier notifier;

  @override
  State<MetronomeLayoutSquare> createState() => _MetronomeLayoutSquareState();
}

class _MetronomeLayoutSquareState extends State<MetronomeLayoutSquare> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: .center,
            children: [
              if (Platform.isWindows)
                CustomIconButton(
                  icon: Icons.arrow_left,
                  padding: .zero,
                  onTap: () {
                    final target = _pageController.page == 0 ? 1 : 0;
                    _pageController.animateToPage(
                      target,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: [
                    Column(
                      mainAxisAlignment: .center,
                      children: [
                        TopButtonGroup(notifier: widget.notifier),
                        SizedBox(height: 32),
                        BpmPanel(notifier: widget.notifier),
                      ],
                    ),
                    PatternPanel(notifier: widget.notifier),
                  ],
                ),
              ),
              if (Platform.isWindows)
                CustomIconButton(
                  icon: Icons.arrow_right,
                  padding: EdgeInsets.zero,
                  onTap: () {
                    final target = _pageController.page == 0 ? 1 : 0;
                    _pageController.animateToPage(
                      target,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        PlayButton(notifier: widget.notifier),
      ],
    );
  }
}
