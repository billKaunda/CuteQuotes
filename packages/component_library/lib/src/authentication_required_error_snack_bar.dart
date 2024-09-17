import 'package:component_library/src/l10n/component_library_localizations.dart';
import 'package:flutter/material.dart';

class AuthenticationRequiredErrorSnackBar extends SnackBar {
  const AuthenticationRequiredErrorSnackBar({super.key})
      : super(
          content: const _AuthenticationRequiredErrorSnackBarMessage(),
        );
}

class _AuthenticationRequiredErrorSnackBarMessage extends StatelessWidget {
  // ignore: unused_element
  const _AuthenticationRequiredErrorSnackBarMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = ComponentLibraryLocalizations.of(context);
    return Text(
      l10n.authenticationRequiredErrorSnackBarMessage,
    );
  }
}
