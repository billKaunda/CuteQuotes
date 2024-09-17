import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/*
This class is useful for changing the status bar color when the screen
doesn't have an AppBar. For screens with AppBars, please use the []
property.
*/
class StyledStatusBar extends StatelessWidget {
  const StyledStatusBar._({
    super.key,
    required this.child,
    required this.style,
  });

  const StyledStatusBar.light({
    Key? key,
    required Widget child,
  }) : this._(
          key: key,
          child: child,
          style: SystemUiOverlayStyle.light,
        );

  const StyledStatusBar.dark({
    Key? key,
    required Widget child,
  }) : this._(
          key: key,
          child: child,
          style: SystemUiOverlayStyle.dark,
        );

  final Widget child;
  final SystemUiOverlayStyle style;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style,
      child: child,
    );
  }
}
