import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/modal_container.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class PatternSelector extends StatelessWidget {
  const PatternSelector({super.key, required this.notifier});
  final MetronomeNotifier notifier;
  @override
  Widget build(BuildContext context) {
    return ModalContainer(child: _buildContent(context));
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: LayoutHelper.getModalContainerTitlePadding(context),
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
