import 'dart:math';

import 'package:flutter/material.dart';

enum LayoutMode { horizontal, square, vertical }

class LayoutHelper {
  LayoutHelper._();

  static const double smallSizeHeight = 450.0;
  static const double smallSizeWidth = 400.0;

  static EdgeInsets getAppPadding(BuildContext context) =>
      isSmallHeight(context)
      ? const EdgeInsets.all(16.0)
      : const EdgeInsets.all(32.0);

  static double getNoteSize(BuildContext context) =>
      isSmallHeight(context) ? 14.0 : 16.0;
  static double getNoteStrokeWidth(BuildContext context) =>
      isSmallHeight(context) ? 2.0 : 3.0;
  static double getPreviewNoteSize(BuildContext context) =>
      isSmallHeight(context) ? 6.0 : 8.0;
  static double getPreviewNoteStrokeWidth(BuildContext context) => 2.0;

  static double getBpmTextSize(BuildContext context) =>
      isSmallHeight(context) ? 98.0 : 128.0;

  static double getPlayButtonHeight(BuildContext context) =>
      isSmallHeight(context) ? 80.0 : 100.0;

  static double getCommonWidgetGap(BuildContext context) =>
      isSmallHeight(context) ? 8.0 : 16.0;

  static double getPickerItemHeight(BuildContext context) =>
      isSmallHeight(context) ? 20.0 : 24.0;

  static double getConfigSliderWidth(BuildContext context) =>
      getLayoutMode(context) == LayoutMode.horizontal
      ? 150.0
      : (isSmallWidth(context) ? 100.0 : 250.0);

  static EdgeInsets getModalContainerPadding(BuildContext context) {
    final mode = getLayoutMode(context);
    switch (mode) {
      case LayoutMode.square:
        return isSmallHeight(context)
            ? const EdgeInsets.all(32.0)
            : const EdgeInsets.all(48.0);
      case LayoutMode.horizontal:
        return isSmallHeight(context)
            ? const EdgeInsets.all(16.0)
            : const EdgeInsets.all(48.0);
      case LayoutMode.vertical:
        return isSmallWidth(context)
            ? const EdgeInsets.fromLTRB(32.0, 96, 32.0, 64.0)
            : const EdgeInsets.fromLTRB(48.0, 128.0, 48.0, 96.0);
    }
  }

  static const double patternGridMinFraction = 0.6;

  static Size getPatternGridMinSize(BuildContext context, {Size? parentSize}) {
    final parent = parentSize ?? MediaQuery.sizeOf(context);
    final fraction = patternGridMinFraction;
    final note = getNoteSize(context);
    final floor = isSmallHeight(context) ? note * 8 : note * 10;

    switch (getLayoutMode(context)) {
      case LayoutMode.square:
        final side = max(floor, min(parent.width, parent.height) * fraction);
        return Size(side, side);
      case LayoutMode.horizontal:
      case LayoutMode.vertical:
        return Size(
          max(floor, parent.width * fraction),
          max(floor, parent.height * fraction),
        );
    }
  }

  static EdgeInsets getModalContainerTitlePadding(BuildContext context) =>
      isSmallHeight(context)
      ? const EdgeInsets.all(8.0)
      : const EdgeInsets.all(16.0);

  static double getToneSelectorItemWidth(BuildContext context) =>
      isSmallWidth(context) ? 120.0 : 160.0;
  static double getToneSelectorItemHeight(BuildContext context) =>
      isSmallHeight(context) ? 40.0 : 100.0;

  static LayoutMode getLayoutMode(BuildContext context) {
    final screenWidth = _windowWidth(context);
    final screenHeight = _windowHeight(context);
    final isWide = screenWidth > screenHeight;
    final ratio =
        min(screenHeight, screenWidth) / max(screenHeight, screenWidth);

    if (ratio > 0.6) return LayoutMode.square;
    if (isWide) return LayoutMode.horizontal;
    return LayoutMode.vertical;
  }

  static double _windowHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double _windowWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static bool isSmallWidth(BuildContext context) =>
      (_windowWidth(context) < smallSizeWidth);

  static bool isSmallHeight(BuildContext context) =>
      (_windowHeight(context) < smallSizeHeight);
}
