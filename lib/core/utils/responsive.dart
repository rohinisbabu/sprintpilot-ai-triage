import 'package:flutter/widgets.dart';

class Responsive {
  const Responsive._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 900;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 900 && width < 1080;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1080;

  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1180) return 40;
    if (width >= 720) return 28;
    return 18;
  }

  static double maxContentWidth(BuildContext context) =>
      isDesktop(context) ? 1180 : double.infinity;
}
