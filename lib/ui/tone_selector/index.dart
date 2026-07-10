import 'package:flutter/material.dart';
import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/core/soloud/soloud_helper.dart';
import 'package:meowtronome/gen/assets.gen.dart';
import 'package:meowtronome/global.dart';
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            'PatternSelector',
            style: titleTextStyle.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: .left,
          ),
          Expanded(
            child: Row(
              children: [
                for (final type in SoundType.values)
                  Expanded(
                    child: WheeledSelector(
                      options: list,
                      value: soloudHelper.getSoundAssetOf(type),
                      onChange: (value) {
                        notifier.setToneForSoundType(type, value);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getLabel(String value) {
    final parts = value.split('/').last.split('.');
    return parts[parts.length - 2].replaceAll('_', ' ');
  }
}
