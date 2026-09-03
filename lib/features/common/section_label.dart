import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// The small all-caps header that introduces a block ("ÚLTIMAS CITAS"). Tone and
/// tracking do the work; there is no rule or heavy weight competing with the
/// content below it.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = Text(
      text.toUpperCase(),
      style: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: RachaType.micro,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    );
    if (trailing == null) return label;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [label, trailing!],
    );
  }
}
