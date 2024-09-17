import 'package:flutter/material.dart';
import '../component_library.dart';

class ChevronListTile extends StatelessWidget {
  const ChevronListTile({
    super.key,
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(
          fontSize: FontSize.mediumLarge,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_outlined,
      ),
      onTap: onTap,
    );
  }
}
