import 'package:flutter/material.dart';

class LayoutHelper {
  LayoutHelper._();

  static const double smallSizeHeight = 450.0;

  static EdgeInsets getAppPadding(BuildContext context) =>
      isSmallHeight(context)
      ? const EdgeInsets.all(16.0)
      : const EdgeInsets.all(32.0);

  static double getNoteSize(BuildContext context) =>
      isSmallHeight(context) ? 10.0 : 12.0;
  static double getNoteStrokeWidth(BuildContext context) =>
      isSmallHeight(context) ? 2.0 : 3.0;

  static double getBpmTextSize(BuildContext context) =>
      isSmallHeight(context) ? 68.0 : 98.0;

  static double getPlayButtonHeight(BuildContext context) =>
      isSmallHeight(context) ? 80.0 : 100.0;

  static double getCommonWidgetGap(BuildContext context) =>
      isSmallHeight(context) ? 8.0 : 16.0;

  static double _windowHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isSmallHeight(BuildContext context) =>
      (_windowHeight(context) < smallSizeHeight);
}
