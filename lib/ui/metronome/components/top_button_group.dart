import 'package:flutter/material.dart';
import 'package:meowtronome/ui/color_helper.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class TopButtonGroup extends StatelessWidget {
  const TopButtonGroup({super.key, required this.notifier});
  final MetronomeNotifier notifier;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CustomIconButton(
          onTap: () => {},
          icon: Icons.list,
          size: 24,
          activeColor: Colors.grey,
          color: iconColor,
          padding: const EdgeInsets.all(8),

          alwaysShowBackground: false,
        ),
        CustomIconButton(
          onTap: () => {},
          icon: Icons.music_note,
          size: 24,
          activeColor: Colors.grey,
          padding: const EdgeInsets.all(8),
          color: iconColor,
          alwaysShowBackground: false,
        ),
        CustomIconButton(
          onTap: () => notifier.openConfigPage(),
          icon: Icons.settings,
          size: 24,
          padding: const EdgeInsets.all(8),
          activeColor: Colors.grey,
          color: iconColor,
          alwaysShowBackground: false,
        ),
      ],
    );
  }
}
