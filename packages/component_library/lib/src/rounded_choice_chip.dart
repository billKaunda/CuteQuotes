import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';

class RoundedChoiceChip extends StatelessWidget {
  const RoundedChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.avatar,
    this.labelColor,
    this.selectedLabelColor,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.onSelected,
  });

  final String label;
  final bool isSelected;
  final Widget? avatar;
  final Color? labelColor;
  final Color? selectedLabelColor;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = CuteTheme.of(context);
    return ChoiceChip(
      shape: const StadiumBorder(
        side: BorderSide(),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? (selectedLabelColor ??
                  theme.roundedChoiceChipSelectedLabelColor)
              : (labelColor ?? theme.roundedChoiceChipLabelColor),
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      avatar: avatar,
      backgroundColor:
          backgroundColor ?? theme.roundedChoiceChipBackgroundColor,
      selectedColor: selectedBackgroundColor ??
          theme.roundedChoiceChipSelectedBackgroundColor,
    );
  }
}
