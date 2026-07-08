import 'package:flutter/material.dart';

class LayoutHelper {
  LayoutHelper._();

  static const double smallSizeHeight = 450.0;

  static EdgeInsets getAppPadding(BuildContext context) {
    return const EdgeInsets.all(32.0);
  }

  static double getNoteSize(BuildContext context) => 10.0;
  static double getNoteStrokeWidth(BuildContext context) => 4.0;

  static double getBpmTextSize(BuildContext context) =>
      (_windowHeight(context) < smallSizeHeight) ? 68.0 : 98.0;

  static double getPlayButtonHeight(BuildContext context) =>
      (_windowHeight(context) < smallSizeHeight) ? 40 : 60.0;

  static double _windowHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  static double _windowWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
}
