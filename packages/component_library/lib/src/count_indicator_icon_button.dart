import '../component_library.dart';
import 'package:flutter/material.dart';

class CountIndicatorIconButton extends StatelessWidget {
  const CountIndicatorIconButton({
    super.key,
    required this.count,
    required this.iconData,
    this.iconColor,
    this.tooltip,
    this.onTap,
  });

  final int count;
  final IconData iconData;
  final Color? iconColor;
  final String? tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      padding: const EdgeInsets.all(0),
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: iconColor,
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: FontSize.small,
            ),
          ),
        ],
      ),
    );
  }
}
