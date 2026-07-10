import 'package:flutter/material.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/selectable_button.dart';
import 'package:meowtronome/ui/config/index.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';
import 'package:meowtronome/ui/pattern_selector/index.dart';
import 'package:meowtronome/ui/tone_selector/index.dart';

class _TabConfig {
  final Widget child;
  final IconData? icon;
  const _TabConfig({required this.child, required this.icon});
}

class TopButtonGroup extends StatefulWidget {
  const TopButtonGroup({super.key, required this.notifier, this.height = 76});
  final MetronomeNotifier notifier;
  final double height;
  @override
  State<TopButtonGroup> createState() => _TopButtonGroupState();
}

class _TopButtonGroupState extends State<TopButtonGroup> {
  late final List<_TabConfig> configs;

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    configs = [
      _TabConfig(
        child: PatternSelector(notifier: widget.notifier),
        icon: Icons.list,
      ),
      _TabConfig(
        child: ToneSelector(notifier: widget.notifier),
        icon: Icons.music_note,
      ),
      _TabConfig(
        child: ConfigPage(notifier: widget.notifier),
        icon: Icons.settings,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _buildTabs(),
      ),
    );
  }

  List<Widget> _buildTabs() {
    final List<Widget> widgets = [];
    for (int i = 0; i < configs.length; i++) {
      widgets.add(
        Expanded(
          child: SelectableButton(
            selected: i == selectedIndex,
            onTap: () {
              setState(() => selectedIndex = i);
              _openModal(configs[i].child);
            },
            icon: configs[i].icon,
            size: 24,
          ),
        ),
      );
      if (i != configs.length - 1) {
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

  void _openModal(Widget child) {
    showDialog(context: context, builder: (context) => child).then(
      (value) => setState(() {
        selectedIndex = -1;
      }),
    );
  }
}
