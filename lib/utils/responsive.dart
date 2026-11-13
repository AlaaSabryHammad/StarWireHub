import 'package:flutter/material.dart';

class Responsive {
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 1250.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBreakpoint;

  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopBreakpoint) return 3;
    if (width >= tabletBreakpoint) return 2;
    return 1;
  }
}
