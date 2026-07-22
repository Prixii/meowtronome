import 'package:flutter/material.dart';
import 'package:meowtronome/global.dart';
import 'package:meowtronome/ui/components/custom_divider.dart';
import 'package:meowtronome/ui/components/selectable_button.dart';

class RadioItemConfig {
  final double size;
  final TextStyle textStyle;

  RadioItemConfig({this.size = 24, this.textStyle = const TextStyle()});
}

class CustomRadio extends StatefulWidget {
  const CustomRadio({
    super.key,
    required this.options,
    required this.config,
    this.initialValue,
    this.axis = .horizontal,
  });

  final List<OptionData> options;
  final String? initialValue;
  final Axis axis;
  final RadioItemConfig config;

  @override
  State<CustomRadio> createState() => _CustomRadioState();
}

class _CustomRadioState extends State<CustomRadio> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue ?? widget.options.first.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.config.size,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: widget.axis == .horizontal
          ? Row(mainAxisSize: .min, children: _buildItems())
          : Column(mainAxisSize: .min, children: _buildItems()),
    );
  }

  List<Widget> _buildItems() {
    List<Widget> widgets = [];
    for (int i = 0; i < widget.options.length; i++) {
      final option = widget.options[i];
      final child = SizedBox(
        width: widget.config.size,
        height: widget.config.size,
        child: SelectableButton(
          selected: option.value == _currentValue,
          text: option.label,
          size: widget.config.size,
          onTap: () => _onSelect(option.value),
        ),
      );

      widgets.add(child);
      if (i != widget.options.length - 1) {
        widgets.add(
          CustomDivider(
            vertical: true,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }

    return widgets;
  }

  void _onSelect(String value) => setState(() => _currentValue = value);
}
