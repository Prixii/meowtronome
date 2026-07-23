import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meowtronome/gen/fonts.gen.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/components/inline_editable_text.dart';
import 'package:meowtronome/ui/haptic_helper.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';
import 'package:provider/provider.dart';

class BpmPanel extends StatelessWidget {
  const BpmPanel({super.key, required this.notifier});
  final MetronomeNotifier notifier;

  TextStyle _textStyle(BuildContext context) => TextStyle(
    fontSize: LayoutHelper.getBpmTextSize(context),
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.primary,
    height: 1,
    fontFamily: FontFamily.doHyeon,
  );

  void _commitBpm(String text) {
    final value = int.tryParse(text);
    if (value != null && value > 0) {
      notifier.setBpm(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bpm = context.select<MetronomeNotifier, int>(
      (notifier) => notifier.bpm,
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      height: 128,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 64,
            child: CustomIconButton(
              icon: Icons.remove,
              size: 24,
              enableLongPressRepeat: true,
              expand: true,
              onTap: () {
                notifier.setBpm(bpm - 1);
                triggerLightHaptic();
              },
            ),
          ),
          CustomDivider(
            vertical: true,
            color: Theme.of(context).colorScheme.primaryFixed,
          ),
          Expanded(
            child: InlineEditableText(
              value: bpm.toString(),
              onSubmit: _commitBpm,
              style: _textStyle(context),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          CustomDivider(
            vertical: true,
            color: Theme.of(context).colorScheme.primaryFixed,
          ),
          SizedBox(
            width: 64,
            child: CustomIconButton(
              icon: Icons.add,
              size: 24,
              enableLongPressRepeat: true,
              expand: true,
              onTap: () {
                notifier.setBpm(bpm + 1);
                triggerLightHaptic();
              },
            ),
          ),
        ],
      ),
    );
  }
}
