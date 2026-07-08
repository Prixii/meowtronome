import 'package:flutter/material.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({super.key, required this.notifier});
  final MetronomeNotifier notifier;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: LayoutHelper.getPlayButtonHeight(context),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.pink,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: IconButton(
        icon: const Icon(Icons.play_arrow),
        color: Colors.white,
        onPressed: () => notifier.toggleRunning(),
      ),
    );
  }
}
