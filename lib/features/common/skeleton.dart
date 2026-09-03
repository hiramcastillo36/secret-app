import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// A single shimmering placeholder block. The brief asks for "skeletons the
/// shape of the content, not full-screen spinners" (audit F, medium: one
/// skeleton in the whole app, 17 screens on a centred CircularProgressIndicator).
///
/// The shimmer is disabled when the platform asks to reduce motion — it then
/// renders as a flat block.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = RachaTokens.brS,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = Color.alphaBlend(
      scheme.onSurface.withValues(alpha: 0.06),
      base,
    );
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      if (_c.isAnimating) _c.stop();
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: widget.borderRadius,
        ),
      );
    }

    if (!_c.isAnimating) _c.repeat();

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1 - 2 * (1 - _c.value), 0),
              end: Alignment(1 - 2 * (1 - _c.value), 0),
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
            ),
          ),
        );
      },
    );
  }
}

/// A vertical run of card-shaped skeletons — the generic "a list is loading"
/// placeholder.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.rows = 6, this.rowHeight = 64});

  final int rows;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(RachaTokens.space4),
      itemCount: rows,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: RachaTokens.space3),
        child: SkeletonBox(height: rowHeight, borderRadius: RachaTokens.brM),
      ),
    );
  }
}
