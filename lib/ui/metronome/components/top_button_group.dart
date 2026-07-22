import 'package:flutter/material.dart';
import 'package:meowtronome/ui/accelerando/index.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/selectable_button.dart';
import 'package:meowtronome/ui/config/index.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';
import 'package:meowtronome/ui/pattern_selector/index.dart';
import 'package:meowtronome/ui/tone_selector/index.dart';

class _TabConfig {
  final Widget Function(MetronomeNotifier) child;
  final IconData? icon;
  const _TabConfig({required this.child, required this.icon});
}

class TopButtonGroup extends StatelessWidget {
  TopButtonGroup({super.key, required this.notifier, this.height = 76});
  final MetronomeNotifier notifier;
  final double height;
  final List<_TabConfig> _configs = [
    _TabConfig(
      child: (notifier) => PatternSelector(metronomeNotifier: notifier),
      icon: Icons.list,
    ),
    _TabConfig(
      child: (notifier) => ToneSelector(notifier: notifier),
      icon: Icons.music_note,
    ),
    _TabConfig(
      child: (notifier) => AccelerandoPage(notifier: notifier),
      icon: Icons.trending_up,
    ),
    _TabConfig(child: (notifier) => ConfigPage(), icon: Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _buildTabs(context),
      ),
    );
  }

  List<Widget> _buildTabs(BuildContext context) {
    final List<Widget> widgets = [];
    for (int i = 0; i < _configs.length; i++) {
      widgets.add(
        Expanded(
          child: SelectableButton(
            selected: i == notifier.runtimeState.selectedTopTabIndex,
            onTap: () {
              notifier.setSelectedTopTabIndex(i);
              _openModal(
                child: _configs[i].child(notifier),
                context: context,
                notifier: notifier,
              );
            },
            icon: _configs[i].icon,
            size: 24,
          ),
        ),
      );
      if (i != _configs.length - 1) {
        widgets.add(
          CustomDivider(
            vertical: true,
            color: Theme.of(context).colorScheme.primaryFixed,
          ),
        );
      }
    }
    return widgets;
  }

  void _openModal({
    required Widget child,
    required BuildContext context,
    required MetronomeNotifier notifier,
  }) {
    showDialog(
      context: context,
      builder: (context) => child,
    ).then((value) => notifier.setSelectedTopTabIndex(-1));
  }
}
