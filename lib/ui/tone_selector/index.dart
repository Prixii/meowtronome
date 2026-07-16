import 'package:flutter/material.dart';
import 'package:meowtronome/core/soloud/soloud_helper.dart';
import 'package:meowtronome/gen/assets.gen.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/modal_container.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/components/animated_note.dart';
import 'package:meowtronome/ui/metronome/components/wheeled_selector.dart';
import 'package:meowtronome/ui/metronome/model.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class ToneSelector extends StatelessWidget {
  const ToneSelector({super.key, required this.notifier});
  final MetronomeNotifier notifier;
  @override
  Widget build(BuildContext context) {
    final toneList = [
      for (final value in Assets.audio.values)
        SelectOption(label: _getLabel(value), value: value),
    ];
    return ModalContainer(child: _buildContent(context, toneList));
  }

  Widget _buildContent(BuildContext context, List<SelectOption> toneList) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: LayoutHelper.getModalContainerTitlePadding(context),
          child: Text(
            '音色',
            style: titleTextStyle.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: .left,
          ),
        ),
        CustomDivider(),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: .min,
              children: _buildNoteTonePickers(toneList, context),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildNoteTonePickers(
    List<SelectOption> toneList,
    BuildContext context,
  ) {
    final List<Widget> widgets = [];
    for (int i = 0; i < noteStyles.length; i++) {
      final style = noteStyles[i];
      widgets.add(_buildSingleNoteTonePicker(context, style, toneList));
      widgets.add(
        CustomDivider(
          vertical: true,
          color: Theme.of(context).colorScheme.primaryFixed,
        ),
      );
    }
    return widgets;
  }

  Widget _buildSingleNoteTonePicker(
    BuildContext context,
    NoteStyle style,
    List<SelectOption> toneList,
  ) {
    return SizedBox(
      width: LayoutHelper.getToneSelectorItemWidth(context),
      child: Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: .stretch,
        children: [
          SizedBox(
            height: LayoutHelper.getToneSelectorItemHeight(context),
            child: Center(
              child: AnimatedNote(
                soundType: style.soundType,
                isPlaying: false,
                size: LayoutHelper.getNoteSize(context),
              ),
            ),
          ),
          CustomDivider(
            color: Theme.of(context).colorScheme.primaryFixed,
            indent: 4,
            endIndent: 4,
          ),
          WheeledSelector(
            options: toneList,
            value: soloudHelper.getSoundAssetOf(style.soundType),
            onChange: (value) {
              notifier.setToneForSoundType(style.soundType, value);
            },
          ),
        ],
      ),
    );
  }

  String _getLabel(String value) {
    final parts = value.split('/').last.split('.');
    return parts[parts.length - 2].replaceAll('_', ' ');
  }
}
