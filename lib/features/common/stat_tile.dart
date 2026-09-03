import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// A single figure in a row of them: a bordered tonal tile with the number in
/// the brand colour and a caption under it. Used on Home and elsewhere a compact
/// stat strip is needed.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: RachaTokens.space3),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: RachaTokens.brM,
          border: Border.all(color: scheme.outlineVariant, width: RachaTokens.borderHairline),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: scheme.primary,
                fontSize: RachaType.headline,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: RachaType.caption),
            ),
          ],
        ),
      ),
    );
  }
}
