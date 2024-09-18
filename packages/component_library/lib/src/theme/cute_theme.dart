import 'cute_theme_data.dart';
import 'package:flutter/material.dart';

class CuteTheme extends InheritedWidget {
  CuteTheme({
    super.key,
    required super.child,
    required this.lightTheme,
    required this.darkTheme,
  });

  final CuteThemeData lightTheme;
  final CuteThemeData darkTheme;

  @override
  bool updateShouldNotify(CuteTheme oldWidget) =>
      oldWidget.lightTheme != lightTheme || oldWidget.darkTheme != darkTheme;

  static CuteThemeData of(BuildContext context) {
    final CuteTheme? inheritedWidget =
        context.dependOnInheritedWidgetOfExactType<CuteTheme>();
    assert(inheritedWidget != null, 'No WonderTheme found in context');
    final currentBrightness = Theme.of(context).brightness;
    return currentBrightness == Brightness.dark
        ? inheritedWidget!.darkTheme
        : inheritedWidget!.lightTheme;
  }
}
