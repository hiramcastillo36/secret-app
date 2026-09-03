import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';

/// 0–4: one point each for length ≥ 8, an uppercase letter, a digit, a symbol.
int passwordScore(String p) {
  if (p.isEmpty) return 0;
  var s = 0;
  if (p.length >= 8) s++;
  if (p.contains(RegExp(r'[A-Z]'))) s++;
  if (p.contains(RegExp(r'[0-9]'))) s++;
  if (p.contains(RegExp(r'[^A-Za-z0-9]'))) s++;
  return s;
}

Color _scoreColor(BuildContext context, int score) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (score) {
    >= 3 => dark ? RachaTokens.okDark : RachaTokens.okLight,
    2 => dark ? RachaTokens.atRiskDark : RachaTokens.atRiskLight,
    _ => Theme.of(context).colorScheme.error,
  };
}

String _scoreLabel(AppLocalizations l10n, int score) => switch (score) {
      >= 4 => l10n.pwStrong,
      3 => l10n.pwGood,
      2 => l10n.pwFair,
      _ => l10n.pwWeak,
    };

/// Four bars that fill with the score, plus a one-word verdict.
class PasswordMeter extends StatelessWidget {
  const PasswordMeter({super.key, required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final score = passwordScore(password);
    final color = _scoreColor(context, score);

    return Padding(
      padding: const EdgeInsets.only(top: RachaTokens.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 1; i <= 4; i++) ...[
                if (i > 1) const SizedBox(width: RachaTokens.space1),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= score ? color : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(RachaTokens.radiusFull),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: RachaTokens.space1),
          Text(_scoreLabel(l10n, score),
              style: TextStyle(
                  color: color, fontSize: RachaType.caption, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// The three-line checklist shown while resetting a password.
class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({super.key, required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ok = Theme.of(context).brightness == Brightness.dark
        ? RachaTokens.okDark
        : RachaTokens.okLight;

    Widget row(String label, bool met) => Padding(
          padding: const EdgeInsets.only(bottom: RachaTokens.space1),
          child: Row(
            children: [
              Icon(met ? Icons.check_circle : Icons.circle_outlined,
                  size: 16, color: met ? ok : scheme.onSurfaceVariant),
              const SizedBox(width: RachaTokens.space2),
              Text(label,
                  style: TextStyle(
                      color: met ? ok : scheme.onSurfaceVariant,
                      fontSize: RachaType.caption)),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row(l10n.pwReqMin8, password.length >= 8),
        row(l10n.pwReqUpper, password.contains(RegExp(r'[A-Z]'))),
        row(l10n.pwReqNumber, password.contains(RegExp(r'[0-9]'))),
      ],
    );
  }
}
