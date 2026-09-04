import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../plans/domain/models.dart';
import '../application/wishlist.dart';
import '../domain/models.dart';

/// /wishlist/roulette — picks one open wish at random. The wheel is decorative;
/// the real choice is [WishlistRepository.pick]. It suggests, never marks
/// anything planned by itself.
class RouletteScreen extends ConsumerStatefulWidget {
  const RouletteScreen({super.key});

  @override
  ConsumerState<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends ConsumerState<RouletteScreen> {
  WishItem? _pick;
  bool _cheap = false;
  bool _busy = false;
  bool _empty = false;
  double _turns = 0;

  Future<void> _spin() async {
    setState(() {
      _busy = true;
      _empty = false;
      _pick = null;
      _turns += 4 + math.Random().nextDouble() * 3;
    });
    try {
      final item = await ref
          .read(wishlistControllerProvider.notifier)
          .pick(cheap: _cheap);
      // Let the wheel finish before the result lands.
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted) setState(() => _pick = item);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _pick = null;
          _empty = e.code == 'wishlist_empty';
        });
        if (!_empty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.localizedMessage(context))));
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels =
        (ref.watch(wishlistProvider).valueOrNull?.open ?? const <WishItem>[])
            .map((w) => w.title.split(' ').first)
            .take(8)
            .toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: RachaTokens.streakGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Text(
                    l10n.rouletteTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: RachaType.headline,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(RachaTokens.space6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 220,
                        width: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedRotation(
                              turns: _turns,
                              duration: const Duration(milliseconds: 3000),
                              curve: Curves.easeInOutCubic,
                              child: CustomPaint(
                                size: const Size(220, 220),
                                painter: _WheelPainter(
                                  segments: labels.length < 3
                                      ? 6
                                      : labels.length,
                                  labels: labels,
                                ),
                              ),
                            ),
                            // Pointer.
                            const Positioned(
                              top: -2,
                              child: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: RachaTokens.space6),
                      if (_empty)
                        Text(
                          l10n.rouletteEmpty,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        )
                      else if (_pick != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(RachaTokens.space5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: RachaTokens.brL,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                l10n.rouletteTitle.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: RachaType.micro,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: RachaTokens.space2),
                              Text(
                                _pick!.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: RachaType.title,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (_pick!.placeName != null) ...[
                                const SizedBox(height: RachaTokens.space1),
                                Text(
                                  _pick!.placeName!,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                              const SizedBox(height: RachaTokens.space4),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: RachaTokens.seed,
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                onPressed: () => context.push(
                                  '/plans/new',
                                  extra: PlanSeed(
                                    title: _pick!.title,
                                    placeId: _pick!.placeId,
                                    placeName: _pick!.placeName,
                                    wishlistItemId: _pick!.id,
                                  ),
                                ),
                                child: Text(l10n.roulettePlanIt),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          l10n.rouletteTitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  RachaTokens.space5,
                  0,
                  RachaTokens.space5,
                  RachaTokens.space5,
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.rouletteCheap,
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: _cheap,
                      activeThumbColor: Colors.white,
                      onChanged: _busy
                          ? null
                          : (v) => setState(() => _cheap = v),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: RachaTokens.seed,
                        minimumSize: const Size.fromHeight(52),
                        disabledBackgroundColor: Colors.white.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      onPressed: _busy ? null : _spin,
                      child: Text(
                        _busy
                            ? l10n.rouletteSpin
                            : _pick == null
                            ? l10n.rouletteSpin
                            : l10n.rouletteAgain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.segments, required this.labels});
  final int segments;
  final List<String> labels;

  static const _palette = [
    Color(0xFF8E2C4E),
    Color(0xFF74565F),
    Color(0xFF7C5635),
    Color(0xFFB26A00),
    Color(0xFF2E7D32),
    Color(0xFF524347),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final sweep = 2 * math.pi / segments;

    for (var i = 0; i < segments; i++) {
      final start = -math.pi / 2 + i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        Paint()..color = _palette[i % _palette.length],
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      if (i < labels.length) {
        final mid = start + sweep / 2;
        final tp = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: radius * 0.7);
        final pos =
            center +
            Offset(math.cos(mid), math.sin(mid)) * (radius * 0.6) -
            Offset(tp.width / 2, tp.height / 2);
        tp.paint(canvas, pos);
      }
    }

    canvas.drawCircle(center, 16, Paint()..color = Colors.white);
    canvas.drawCircle(center, 10, Paint()..color = _palette.first);
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.segments != segments || old.labels != labels;
}
