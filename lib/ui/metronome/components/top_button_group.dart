import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';
import 'package:meowtronome/ui/tone_selector/index.dart';

class TopButtonGroup extends StatefulWidget {
  const TopButtonGroup({super.key, required this.notifier, this.height = 76});
  final MetronomeNotifier notifier;
  final double height;
  @override
  State<TopButtonGroup> createState() => _TopButtonGroupState();
}

class _TopButtonGroupState extends State<TopButtonGroup> {
  void _openModal(Widget child) {
    showDialog(
      context: context,
      builder: (context) {
        final size = MediaQuery.sizeOf(context);
        return SizedBox(
          width: size.width * 0.85,
          height: size.height * 0.5,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: CustomIconButton(
              onTap: () => _openModal(
                _TopButtonModalBody(title: '节奏列表', notifier: widget.notifier),
              ),
              icon: Icons.list,
              size: 24,
            ),
          ),
          CustomDivider(
            vertical: true,
            color: Theme.of(context).colorScheme.primaryFixed,
          ),
          Expanded(
            child: CustomIconButton(
              onTap: () => _openModal(
                _TopButtonModalBody(title: '音色选择', notifier: widget.notifier),
              ),
              icon: Icons.music_note,
              size: 24,
            ),
          ),
          CustomDivider(
            vertical: true,
            color: Theme.of(context).colorScheme.primaryFixed,
          ),
          Expanded(
            child: CustomIconButton(
              onTap: () => widget.notifier.openConfigPage(),
              icon: Icons.settings,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopButtonModalBody extends StatelessWidget {
  const _TopButtonModalBody({required this.title, required this.notifier});
  final MetronomeNotifier notifier;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titleTextStyle),
              const SizedBox(height: 16),
              Expanded(child: ToneSelector(notifier: notifier)),
            ],
          ),
        ),
      ),
    );
  }
}
