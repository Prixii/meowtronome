import 'package:flutter/material.dart';
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
          color: Colors.black,
        ),
        CustomIconButton(
          onTap: () => {},
          icon: Icons.music_note,
          size: 24,
          activeColor: Colors.grey,
          color: Colors.black,
        ),
        CustomIconButton(
          onTap: () => notifier.openConfigPage(),
          icon: Icons.settings,
          size: 24,
          activeColor: Colors.grey,
          color: Colors.black,
        ),
      ],
    );
  }
}
