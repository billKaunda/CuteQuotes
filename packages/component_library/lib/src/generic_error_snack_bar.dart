import 'package:flutter/material.dart';
import 'package:component_library/component_library.dart';

class GenericErrorSnackBar extends SnackBar {
  const GenericErrorSnackBar({
    super.key,
  }) : super(content: const _GenericErrorSnackBarMessage());
}

class _GenericErrorSnackBarMessage extends StatelessWidget {
  // ignore: unused_element
  const _GenericErrorSnackBarMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = ComponentLibraryLocalizations.of(context);
    return Text(
      l10n.genericErrorSnackBarMessage,
    );
  }
}
