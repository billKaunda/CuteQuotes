import 'package:flutter/material.dart';

class ExpandedElevatedButton extends StatelessWidget {
  static const double _elevatedButtonHeight = 48;

  const ExpandedElevatedButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
  });

  ExpandedElevatedButton.inProgress({
    Key? key,
    required String label,
  }) : this(
          key: key,
          label: label,
          icon: Transform.scale(
            scale: 0.5,
            child: const CircularProgressIndicator(),
          ),
        );

  final String label;
  final VoidCallback? onTap;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return SizedBox(
      height: _elevatedButtonHeight,
      width: double.infinity,
      child: icon != null 
        ? ElevatedButton.icon(
          onPressed: onTap,
          label: Text(label,),
          icon: icon,
        )
        : ElevatedButton(
          onPressed: onTap,
          child: Text(
            label,
          ),
        ),
    );
  }
}
