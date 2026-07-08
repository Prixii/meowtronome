import 'package:flutter/material.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({super.key, required this.notifier});
  final MetronomeNotifier notifier;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => notifier.toggleRunning(),
      child: Container(
        height: LayoutHelper.getPlayButtonHeight(context),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Icon(
          Icons.play_arrow,
          size: LayoutHelper.getPlayButtonHeight(context) * 0.8,
          color: Colors.white,
        ),
      ),
    );
  }
}
