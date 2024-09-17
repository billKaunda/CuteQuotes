import 'package:flutter/material.dart';
import 'package:component_library/component_library.dart';

class DownvoteIconButton extends StatelessWidget {
  const DownvoteIconButton({
    super.key,
    required this.count,
    required this.isDownvoted,
    this.onTap,
  });

  final int count;
  final bool isDownvoted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = ComponentLibraryLocalizations.of(context);
    final theme = WonderTheme.of(context);

    return CountIndicatorIconButton(
      count: count,
      onTap: onTap,
      tooltip: l10n.downvoteIconButtonTooltip,
      iconData: Icons.arrow_downward_sharp,
      iconColor:
          isDownvoted ? theme.votedButtonColor : theme.unvotedButtonColor,
    );
  }
}
