import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';

class FavoriteIconButton extends StatelessWidget {
  const FavoriteIconButton({
    super.key,
    required this.isFavorite,
    this.onTap,
  });

  final bool isFavorite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = ComponentLibraryLocalizations.of(context);
    return IconButton(
      onPressed: onTap,
      tooltip: l10n.favoriteIconButtonTooltip,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
      ),
    );
  }
}
