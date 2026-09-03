import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// A bordered, rounded container that stacks setting rows with hairline dividers
/// between them. Pass [danger] to tint the border for a destructive group.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children, this.danger = false});

  final List<Widget> children;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: RachaTokens.brM,
        border: Border.all(
          color: danger ? scheme.error.withValues(alpha: 0.4) : scheme.outlineVariant,
          width: RachaTokens.borderHairline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, color: scheme.outlineVariant),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// One tappable row inside a [SettingsGroup]: leading icon, label, optional
/// trailing value, and a chevron (hidden for [danger] rows).
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = danger ? scheme.error : scheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: RachaTokens.space4, vertical: RachaTokens.space3),
        child: Row(
          children: [
            Icon(icon, size: 20, color: danger ? scheme.error : scheme.onSurfaceVariant),
            const SizedBox(width: RachaTokens.space3),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: RachaType.callout,
                      fontWeight: FontWeight.w600)),
            ),
            if (value != null) ...[
              Text(value!,
                  style: TextStyle(
                      color: scheme.onSurfaceVariant, fontSize: RachaType.caption)),
              const SizedBox(width: RachaTokens.space1),
            ],
            if (!danger) Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
