import 'wonder_theme_data.dart';
import 'package:flutter/material.dart';

class WonderTheme extends InheritedWidget {
  WonderTheme({
    super.key,
    required super.child,
    required this.lightTheme,
    required this.darkTheme,
  });

  final WonderThemeData lightTheme;
  final WonderThemeData darkTheme;

  @override
  bool updateShouldNotify(WonderTheme oldWidget) =>
      oldWidget.lightTheme != lightTheme || oldWidget.darkTheme != darkTheme;

  static WonderThemeData of(BuildContext context) {
    final WonderTheme? inheritedWidget =
        context.dependOnInheritedWidgetOfExactType<WonderTheme>();
    assert(inheritedWidget != null, 'No WonderTheme found in context');
    final currentBrightness = Theme.of(context).brightness;
    return currentBrightness == Brightness.dark
        ? inheritedWidget!.darkTheme
        : inheritedWidget!.lightTheme;
  }
}
