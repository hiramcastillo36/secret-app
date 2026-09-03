import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../auth/presentation/auth_hero.dart';

/// The fork after registration: create the couple (become owner) or join with a
/// code. It cannot be skipped — without a couple there is no streak.
class CoupleSetupScreen extends StatelessWidget {
  const CoupleSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHero(title: l10n.coupleSetupTitle, subtitle: l10n.coupleSetupSubtitle),
            Padding(
              padding: const EdgeInsets.all(RachaTokens.space5),
              child: Column(
                children: [
                  _OptionCard(
                    icon: Icons.favorite,
                    title: l10n.coupleSetupCreate,
                    subtitle: l10n.coupleSetupCreateSub,
                    highlighted: true,
                    onTap: () => context.push('/couple/create'),
                  ),
                  const SizedBox(height: RachaTokens.space3),
                  _OptionCard(
                    icon: Icons.vpn_key_outlined,
                    title: l10n.coupleSetupJoin,
                    subtitle: l10n.coupleSetupJoinSub,
                    onTap: () => context.push('/couple/join'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: highlighted ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: RachaTokens.brM,
        side: BorderSide(
          color: highlighted ? scheme.primary : scheme.outlineVariant,
          width: highlighted ? 1.5 : RachaTokens.borderHairline,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(RachaTokens.space4),
          child: Row(
            children: [
              Icon(icon,
                  size: 28,
                  color: highlighted ? scheme.onPrimaryContainer : scheme.primary),
              const SizedBox(width: RachaTokens.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontSize: RachaType.body,
                          fontWeight: FontWeight.w800,
                          color: highlighted ? scheme.onPrimaryContainer : scheme.onSurface,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                          fontSize: RachaType.caption,
                          color: highlighted
                              ? scheme.onPrimaryContainer.withValues(alpha: 0.8)
                              : scheme.onSurfaceVariant,
                        )),
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
