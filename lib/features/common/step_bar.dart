import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// The 1–2 step progress used by the modal add flows: a row of segments, the
/// reached ones filled, with a caption under it. Sits in an [AppBar.bottom].
class StepBar extends StatelessWidget implements PreferredSizeWidget {
  const StepBar({
    super.key,
    required this.step,
    required this.total,
    required this.label,
  });

  final int step;
  final int total;
  final String label;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RachaTokens.space4,
        0,
        RachaTokens.space4,
        RachaTokens.space3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 1; i <= total; i++) ...[
                if (i > 1) const SizedBox(width: RachaTokens.space2),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= step
                          ? scheme.primary
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        RachaTokens.radiusFull,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: RachaTokens.space2),
          Text(
            label,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: RachaType.micro,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
