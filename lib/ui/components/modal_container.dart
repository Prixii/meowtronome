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
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildWide(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container()),
        Expanded(
          child: Padding(
            padding: LayoutHelper.getModalContainerPadding(context),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
