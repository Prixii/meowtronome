import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class PatternSelector extends StatelessWidget {
  const PatternSelector({super.key, required this.notifier});
  final MetronomeNotifier notifier;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Text(
        'PatternSelector',
        style: titleTextStyle.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
