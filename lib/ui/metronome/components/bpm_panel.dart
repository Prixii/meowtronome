import 'package:flutter/material.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class BpmPanel extends StatelessWidget {
  const BpmPanel({super.key, required this.notifier});
  final MetronomeNotifier notifier;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary),
      height: 128,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            child: CustomIconButton(
              icon: Icons.remove,
              size: 24,
              onTap: () => notifier.setBpm(notifier.bpm - 1),
            ),
          ),
          CustomDivider(indent: 12, endIndent: 12, vertical: true),
          Expanded(
            child: Text(
              notifier.bpm.toString(),
              style: TextStyle(
                fontSize: LayoutHelper.getBpmTextSize(context),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                height: 1,
              ),
              textAlign: .center,
            ),
          ),
          CustomDivider(indent: 12, endIndent: 12, vertical: true),
          SizedBox(
            width: 64,
            child: CustomIconButton(
              icon: Icons.add,
              size: 24,
              onTap: () => notifier.setBpm(notifier.bpm + 1),
            ),
          ),
        ],
      ),
    );
  }
}
