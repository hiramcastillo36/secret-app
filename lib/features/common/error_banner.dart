import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Inline error surface: tone + 1px border, never a dialog.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(RachaTokens.space3),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: RachaTokens.brS,
        border: Border.all(color: scheme.error, width: RachaTokens.borderHairline),
      ),
      child: Text(text, style: TextStyle(color: scheme.onErrorContainer)),
    );
  }
}
