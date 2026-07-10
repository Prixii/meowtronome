import 'dart:math';

import 'package:flutter/material.dart';

enum LayoutMode { horizontal, square, vertical }

class LayoutHelper {
  LayoutHelper._();

  static const double smallSizeHeight = 450.0;

  static EdgeInsets getAppPadding(BuildContext context) =>
      isSmallHeight(context)
      ? const EdgeInsets.all(16.0)
      : const EdgeInsets.all(32.0);

  static double getNoteSize(BuildContext context) =>
      isSmallHeight(context) ? 14.0 : 16.0;
  static double getNoteStrokeWidth(BuildContext context) =>
      isSmallHeight(context) ? 2.0 : 3.0;

  static double getBpmTextSize(BuildContext context) =>
      isSmallHeight(context) ? 98.0 : 128.0;

  static double getPlayButtonHeight(BuildContext context) =>
      isSmallHeight(context) ? 80.0 : 100.0;

  static double getCommonWidgetGap(BuildContext context) =>
      isSmallHeight(context) ? 8.0 : 16.0;

  static double getPickerItemHeight(BuildContext context) =>
      isSmallHeight(context) ? 20.0 : 24.0;

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

  static bool isSmallHeight(BuildContext context) =>
      (_windowHeight(context) < smallSizeHeight);
}
