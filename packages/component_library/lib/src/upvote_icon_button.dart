import 'package:flutter/material.dart';
import 'package:component_library/component_library.dart';

class UpvoteIconButton extends StatelessWidget {
  const UpvoteIconButton({
    super.key,
    required this.count,
    required this.isUpvoted,
    this.onTap,
  });

  final int count;
  final bool isUpvoted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = ComponentLibraryLocalizations.of(context);
    final theme = CuteTheme.of(context);

    return CountIndicatorIconButton(
      count: count,
      iconData: Icons.arrow_upward_sharp,
      iconColor: isUpvoted ? theme.votedButtonColor : theme.unvotedButtonColor,
      onTap: onTap,
      tooltip: l10n.upvoteIconButtonTooltip,
    );
  }
}
