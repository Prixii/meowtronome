import 'package:flutter/material.dart';
import 'package:meowtronome/gen/assets.gen.dart';
import 'package:meowtronome/ui/metronome/components/wheeled_selector.dart';

class ToneSelector extends StatelessWidget {
  const ToneSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final list = [
      for (final value in Assets.audio.values)
        SelectOption(label: value, value: value),
    ];
    return Row(
      children: [
        Expanded(
          child: WheeledSelector(
            options: list,
            value: list[0].value,
            onChange: (value) {},
          ),
        ),
      ],
    );
  }
}
