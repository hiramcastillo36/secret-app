import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// A bordered, tappable row that stands in for a native picker field: a caption
/// over the current value, a trailing icon, the whole thing tinted like an input.
class FieldTile extends StatelessWidget {
  const FieldTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: RachaTokens.brS,
        side: BorderSide(
          color: scheme.outlineVariant,
          width: RachaTokens.borderHairline,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RachaTokens.space4,
            vertical: RachaTokens.space3,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: RachaType.caption,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// The soft explanatory panel used across the streak flows. [tone] "warning"
/// tints it amber; the default is a neutral surface.
class NoteBox extends StatelessWidget {
  const NoteBox({
    super.key,
    required this.child,
    this.tone = 'neutral',
    this.icon,
  });

  final Widget child;
  final String tone; // neutral | warning
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final warning = tone == 'warning';
    final bg = warning
        ? (dark ? RachaTokens.atRiskDark : RachaTokens.atRiskLight).withValues(
            alpha: 0.14,
          )
        : scheme.surfaceContainerHighest;
    final fg = warning
        ? (dark ? RachaTokens.atRiskDark : RachaTokens.atRiskLight)
        : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(RachaTokens.space4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: RachaTokens.brM,
        border: warning
            ? null
            : Border.all(
                color: scheme.outlineVariant,
                width: RachaTokens.borderHairline,
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: RachaTokens.space2),
          ],
          Expanded(
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: fg,
                fontSize: RachaType.caption,
                height: 1.4,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
