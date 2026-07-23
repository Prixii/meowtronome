import 'package:flutter/material.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
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
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  Column(
                    children: [
                      TopButtonGroup(notifier: widget.notifier),
                      CustomDivider(),
                      Expanded(child: BpmPanel(notifier: widget.notifier)),
                    ],
                  ),
                  PatternPanel(notifier: widget.notifier),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildPageSwitcher(context),
              ),
            ],
          ),
        ),
        CustomDivider(),
        const PlayButton(),
      ],
    );
  }

  Widget _buildPageSwitcher(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(context, page: 0),
          const SizedBox(width: 8),
          _buildDot(context, page: 1),
        ],
      ),
    );
  }

  Widget _buildDot(BuildContext context, {required int page}) {
    final selected = _currentPage == page;
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (_currentPage == page) return;
          _pageController.animateToPage(
            page,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.primaryFixed,
            ),
            borderRadius: BorderRadius.zero,
            color: selected ? colorScheme.primary : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
