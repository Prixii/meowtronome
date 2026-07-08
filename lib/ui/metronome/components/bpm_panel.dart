import 'package:flutter/material.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class BpmPanel extends StatelessWidget {
  const BpmPanel({super.key, required this.notifier});
  final MetronomeNotifier notifier;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.pink,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomIconButton(
            icon: Icons.remove,
            size: LayoutHelper.getBpmTextSize(context),
            padding: const EdgeInsets.all(4),
            activeColor: Colors.grey,
            color: Colors.white,
            onTap: () => notifier.setBpm(notifier.bpm - 1),
            alwaysShowBackground: false,
          ),
          Expanded(
            child: Text(
              notifier.bpm.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: LayoutHelper.getBpmTextSize(context),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          CustomIconButton(
            icon: Icons.add,
            size: LayoutHelper.getBpmTextSize(context),
            activeColor: Colors.grey,
            color: Colors.white,
            padding: const EdgeInsets.all(4),
            onTap: () => notifier.setBpm(notifier.bpm + 1),
            alwaysShowBackground: false,
          ),
        ],
      ),
    );
  }
}
