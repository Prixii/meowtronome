import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/color_helper.dart';
import 'package:meowtronome/ui/components/custom_icon_button.dart';
import 'package:meowtronome/ui/components/expand_rrect_modal.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class TopButtonGroup extends StatefulWidget {
  const TopButtonGroup({super.key, required this.notifier});
  final MetronomeNotifier notifier;

  @override
  State<TopButtonGroup> createState() => _TopButtonGroupState();
}

class _TopButtonGroupState extends State<TopButtonGroup> {
  final _listButtonKey = GlobalKey();
  final _musicButtonKey = GlobalKey();

  void _openModal(GlobalKey anchorKey, String title) {
    showExpandRRectModal(
      context: context,
      anchorKey: anchorKey,
      builder: (context) => _TopButtonModalBody(title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CustomIconButton(
          key: _listButtonKey,
          onTap: () => _openModal(_listButtonKey, '节奏列表'),
          icon: Icons.list,
          size: 24,
          activeColor: Colors.grey,
          color: iconColor,
          padding: const EdgeInsets.all(8),
          alwaysShowBackground: false,
        ),
        CustomIconButton(
          key: _musicButtonKey,
          onTap: () => _openModal(_musicButtonKey, '音色选择'),
          icon: Icons.music_note,
          size: 24,
          activeColor: Colors.grey,
          padding: const EdgeInsets.all(8),
          color: iconColor,
          alwaysShowBackground: false,
        ),
        CustomIconButton(
          onTap: () => widget.notifier.openConfigPage(),
          icon: Icons.settings,
          size: 24,
          padding: const EdgeInsets.all(8),
          activeColor: Colors.grey,
          color: iconColor,
          alwaysShowBackground: false,
        ),
      ],
    );
  }
}

class _TopButtonModalBody extends StatelessWidget {
  const _TopButtonModalBody({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleTextStyle),
          const SizedBox(height: 16),
          Text('内容待实现', style: bodyTextStyle),
        ],
      ),
    );
  }
}
