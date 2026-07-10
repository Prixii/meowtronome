import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class PatternSelector extends StatelessWidget {
  const PatternSelector({super.key, required this.notifier});
  final MetronomeNotifier notifier;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '节奏',
            style: titleTextStyle.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: .left,
          ),
        ),
        Expanded(child: Placeholder()),
      ],
    );
  }
}
