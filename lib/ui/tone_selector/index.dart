import 'package:flutter/material.dart';
import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/core/soloud/soloud_helper.dart';
import 'package:meowtronome/gen/assets.gen.dart';
import 'package:meowtronome/ui/metronome/components/wheeled_selector.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class ToneSelector extends StatelessWidget {
  const ToneSelector({super.key, required this.notifier});
  final MetronomeNotifier notifier;
  @override
  Widget build(BuildContext context) {
    final list = [
      for (final value in Assets.audio.values)
        SelectOption(label: getLabel(value), value: value),
    ];
    return Row(
      children: [
        for (final type in SoundType.values)
          Expanded(
            child: WheeledSelector(
              options: list,
              value: soloudHelper.getSoundAssetOf(type),
              onChange: (value) {},
            ),
          ),
      ],
    );
  }

  String getLabel(String value) {
    final parts = value.split('/').last.split('.');
    return parts[parts.length - 2].replaceAll('_', ' ');
  }
}
