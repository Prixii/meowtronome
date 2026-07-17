import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/components/inline_editable_text.dart';
import 'package:meowtronome/ui/components/modal_container.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';
import 'package:meowtronome/ui/pattern_selector/components/rhythm_pattern_item.dart';
import 'package:meowtronome/ui/pattern_selector/provider/pattern_selector_notifier.dart';
import 'package:provider/provider.dart';

class PatternSelector extends StatelessWidget {
  const PatternSelector({super.key, required this.metronomeNotifier});
  final MetronomeNotifier metronomeNotifier;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PatternSelectorNotifier(),
      child: ModalContainer(
        child: UnfocusOnPointerOutside(
          child: PatternSelectorBody(metronomeNotifier: metronomeNotifier),
        ),
      ),
    );
  }
}

class PatternSelectorBody extends StatelessWidget {
  const PatternSelectorBody({super.key, required this.metronomeNotifier});

  final MetronomeNotifier metronomeNotifier;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PatternSelectorNotifier>();

    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: LayoutHelper.getModalContainerTitlePadding(context),
                child: Text(
                  '节奏',
                  style: titleTextStyle.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: .left,
                ),
              ),
            ),
            Padding(
              padding: LayoutHelper.getModalContainerTitlePadding(context),
              child: CustomIconButton(
                icon: Icons.add,
                size: 32,
                onTap: () => notifier.addPattern(metronomeNotifier.pattern),
              ),
            ),
          ],
        ),
        CustomDivider(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final pattern in notifier.systemPatterns)
                  RhythmPatternItem(
                    pattern: pattern,
                    uuid: pattern.name,
                    isSystemPattern: true,
                    onSelect: () {
                      metronomeNotifier.setPattern(pattern);
                      Navigator.pop(context);
                    },
                    onRename: (newName) => {},
                    onDelete: () => {},
                  ),
                ...[
                  for (final patternEntry in notifier.userPatterns.entries)
                    RhythmPatternItem(
                      pattern: patternEntry.value,
                      uuid: patternEntry.key,
                      onSelect: () {
                        metronomeNotifier.setPattern(patternEntry.value);
                        Navigator.pop(context);
                      },
                      onRename: (newName) =>
                          notifier.renamePattern(patternEntry.key, newName),
                      onDelete: () => notifier.deletePattern(patternEntry.key),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
