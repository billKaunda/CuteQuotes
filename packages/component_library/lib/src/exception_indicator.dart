import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';

class ExceptionIndicator extends StatelessWidget {
  const ExceptionIndicator({
    super.key,
    this.title,
    this.message,
    this.onTryAgain,
  });

  final String? title;
  final String? message;
  final VoidCallback? onTryAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = ComponentLibraryLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 32,
          horizontal: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              size: 48,
            ),
            SizedBox(
              height: Spacing.xxLarge,
            ),
            Text(
              title ?? l10n.exceptionIndicatorGenericTitle,
              style: TextStyle(
                fontSize: FontSize.mediumLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: Spacing.mediumLarge,
            ),
            Text(
              message ?? l10n.exceptionIndicatorGenericMessage,
              textAlign: TextAlign.center,
            ),
            if(onTryAgain != null)
            const SizedBox(
              height: Spacing.xxxLarge,
            ),
            if(onTryAgain != null)
            ExpandedElevatedButton(
              onTap: onTryAgain,
              icon: const Icon(Icons.refresh),
              label: l10n.exceptionIndicatorTryAgainButton,
            ),
          ],
        ),
      ),
    );
  }
}
