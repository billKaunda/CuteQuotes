import 'package:flutter/material.dart';

class InProgressTextButton extends StatelessWidget {
  const InProgressTextButton({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: null,
      icon: Transform.scale(
        scale: 0.5,
        child: const CircularProgressIndicator(),
      ),
      label: Text(label),
    );
  }
}
