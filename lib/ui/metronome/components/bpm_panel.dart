import 'package:flutter/material.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class BpmPanel extends StatelessWidget {
  const BpmPanel({super.key, required this.notifier});
  final MetronomeNotifier notifier;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          notifier.bpm.toString(),
          style: const TextStyle(fontSize: 98, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomIconButton(
                icon: Icons.remove,
                size: 24,
                padding: const EdgeInsets.all(0),
                activeColor: Colors.grey,
                color: Colors.black,
                onTap: () => notifier.setBpm(notifier.bpm - 1),
              ),
              Expanded(
                child: Slider(
                  value: notifier.bpm.toDouble(),
                  max: 300,
                  min: 10,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ),
                  onChanged: (newValue) => {
                    notifier.setBpm((newValue).toInt()),
                  },
                  // ignore: deprecated_member_use
                  year2023: false,
                ),
              ),
              CustomIconButton(
                icon: Icons.add,
                size: 24,
                activeColor: Colors.grey,
                color: Colors.black,
                padding: const EdgeInsets.all(0),
                onTap: () => notifier.setBpm(notifier.bpm + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
