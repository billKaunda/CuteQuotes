import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';

class ShareIconButton extends StatelessWidget {
  const ShareIconButton({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = ComponentLibraryLocalizations.of(context);
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: onTap,
      tooltip: l10n.shareIconButtonTooltip,
    );
  }
}
