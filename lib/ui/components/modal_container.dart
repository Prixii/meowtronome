import 'package:flutter/material.dart';
import 'package:meowtronome/ui/layout_helper.dart';

class ModalContainer extends StatelessWidget {
  const ModalContainer({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    switch (LayoutHelper.getLayoutMode(context)) {
      case LayoutMode.square:
        return _buildNormal(context);
      case LayoutMode.horizontal:
        return _buildWide(context);
      case LayoutMode.vertical:
        return _buildNormal(context);
    }
  }

  Widget _buildNormal(BuildContext context) {
    return Padding(
      padding: LayoutHelper.getModalContainerPadding(context),
      child: _buildModalContent(context),
    );
  }

  Widget _buildWide(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: LayoutHelper.getModalContainerPadding(context),
            child: _buildModalContent(context),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget _buildModalContent(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}
