import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meowtronome/core/accelerando.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/inline_editable_text.dart';
import 'package:meowtronome/ui/components/modal_container.dart';
import 'package:meowtronome/ui/config/components/config_item.dart';
import 'package:meowtronome/ui/config/components/custom_switch.dart';
import 'package:meowtronome/ui/layout_helper.dart';
import 'package:meowtronome/ui/metronome/provider/metronome_notifier.dart';

class AccelerandoPage extends StatelessWidget {
  const AccelerandoPage({super.key, required this.notifier});

  final MetronomeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ModalContainer(
      child: UnfocusOnPointerOutside(
        child: ListenableBuilder(
          listenable: notifier,
          builder: (context, _) => _AccelerandoBody(notifier: notifier),
        ),
      ),
    );
  }
}

class _AccelerandoBody extends StatelessWidget {
  const _AccelerandoBody({required this.notifier});

  final MetronomeNotifier notifier;

  AccelerandoConfig get _config => notifier.accelerando;

  void _update(AccelerandoConfig config) {
    notifier.setAccelerando(config);
  }

  void _commitInt(String text, void Function(int value) apply) {
    final value = int.tryParse(text);
    if (value == null) return;
    apply(value);
  }

  @override
  Widget build(BuildContext context) {
    final padding = LayoutHelper.getModalContainerTitlePadding(context);
    final dividerColor = Theme.of(context).colorScheme.primaryFixed;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: padding,
          child: Text(
            '自动加速',
            style: titleTextStyle.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: .left,
          ),
        ),
        const CustomDivider(),
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: .start,
                children: [
                  ConfigItem(
                    title: '启用',
                    description: '播放时从起始 BPM 按小节自动递增',
                    trailing: CustomSwitch(
                      value: _config.enabled,
                      onChanged: (value) =>
                          _update(_config.copyWith(enabled: value)),
                    ),
                    padding: padding,
                  ),
                  CustomDivider(indent: 1, endIndent: 1, color: dividerColor),
                  ConfigItem(
                    title: '起始 BPM',
                    trailing: _NumberField(
                      value: _config.startBpm,
                      onSubmit: (text) => _commitInt(
                        text,
                        (value) => _update(_config.copyWith(startBpm: value)),
                      ),
                    ),
                    padding: padding,
                  ),
                  CustomDivider(indent: 1, endIndent: 1, color: dividerColor),
                  ConfigItem(
                    title: '结束 BPM',
                    trailing: _NumberField(
                      value: _config.endBpm,
                      onSubmit: (text) => _commitInt(
                        text,
                        (value) => _update(_config.copyWith(endBpm: value)),
                      ),
                    ),
                    padding: padding,
                  ),
                  CustomDivider(indent: 1, endIndent: 1, color: dividerColor),
                  ConfigItem(
                    title: '每多少小节',
                    trailing: _NumberField(
                      value: _config.barsPerStep,
                      onSubmit: (text) => _commitInt(
                        text,
                        (value) =>
                            _update(_config.copyWith(barsPerStep: value)),
                      ),
                    ),
                    padding: padding,
                  ),
                  CustomDivider(indent: 1, endIndent: 1, color: dividerColor),
                  ConfigItem(
                    title: 'BPM 增量',
                    trailing: _NumberField(
                      value: _config.bpmStep,
                      onSubmit: (text) => _commitInt(
                        text,
                        (value) => _update(_config.copyWith(bpmStep: value)),
                      ),
                    ),
                    padding: padding,
                  ),
                  const CustomDivider(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.value, required this.onSubmit});

  final int value;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: InlineEditableText(
        value: value.toString(),
        onSubmit: onSubmit,
        style: subtitleTextStyle.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
        textAlign: .right,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }
}
