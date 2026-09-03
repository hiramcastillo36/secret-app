import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/error_retry.dart';
import '../../common/skeleton.dart';
import '../../dates/application/dates.dart';
import '../application/protect.dart';

/// /streak/protect — the hub: season progress, the free monthly pause, any
/// active freeze, and repairs that need an answer.
class ProtectScreen extends ConsumerWidget {
  const ProtectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hub = ref.watch(protectHubProvider);
    final streak = ref.watch(streakProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.protectTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(protectHubProvider);
          ref.invalidate(streakProvider);
          await ref.read(protectHubProvider.future);
        },
        child: hub.when(
          loading: () => const SkeletonList(rows: 4, rowHeight: 96),
          error: (_, __) => ListView(
            children: [
              const SizedBox(height: 120),
              ErrorRetry(
                onRetry: () {
                  ref.invalidate(protectHubProvider);
                  ref.invalidate(streakProvider);
                },
              ),
            ],
          ),
          data: (h) => ListView(
            padding: const EdgeInsets.all(RachaTokens.space5),
            children: [
              _Intro(streak: streak?.currentStreak),
              const SizedBox(height: RachaTokens.space5),
              if (streak != null) ...[
                _SeasonCard(
                  record: streak.recordStreak,
                  best: streak.season.best,
                  length: streak.season.length,
                ),
                const SizedBox(height: RachaTokens.space4),
              ],
              _FreezeSection(hub: h),
              const SizedBox(height: RachaTokens.space4),
              _RepairSection(hub: h),
            ],
          ),
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({this.streak});
  final int? streak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(Icons.shield_outlined, size: 40, color: scheme.primary),
        const SizedBox(height: RachaTokens.space2),
        Text(
          streak == null ? l10n.protectIntro : l10n.protectIntroWeeks(streak!),
          textAlign: TextAlign.center,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// The prototype's big action row: icon, title, one line of "what this does",
/// chevron. Disabled rows dim and stop responding.
class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: scheme.surfaceContainerHighest,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: RachaTokens.brM,
          side: BorderSide(
            color: scheme.outlineVariant,
            width: RachaTokens.borderHairline,
          ),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(RachaTokens.space4),
            child: Row(
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: RachaTokens.space4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: RachaType.caption,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeasonCard extends StatelessWidget {
  const _SeasonCard({
    required this.record,
    required this.best,
    required this.length,
  });
  final int record;
  final int best;
  final String length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final label = switch (length) {
      'quarterly' => l10n.protectSeasonQuarterly,
      'infinite' => l10n.protectSeasonInfinite,
      _ => l10n.protectSeasonMonthly,
    };
    return Container(
      padding: const EdgeInsets.all(RachaTokens.space4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: RachaTokens.brM,
        border: Border.all(
          color: scheme.outlineVariant,
          width: RachaTokens.borderHairline,
        ),
      ),
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
          const SizedBox(height: RachaTokens.space2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(value: best, label: l10n.protectSeasonBest),
              _Stat(value: record, label: l10n.protectRecord),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: RachaType.title,
            fontWeight: FontWeight.w800,
            color: scheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: RachaType.caption,
          ),
        ),
      ],
    );
  }
}

class _FreezeSection extends ConsumerWidget {
  const _FreezeSection({required this.hub});
  final ProtectHub hub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final f = hub.activeFreeze;

    if (f != null) {
      return Container(
        padding: const EdgeInsets.all(RachaTokens.space4),
        decoration: BoxDecoration(
          color: RachaTokens.atRiskDark.withValues(alpha: 0.15),
          borderRadius: RachaTokens.brM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.protectActiveFreezeFrom(f.startsWeekKey, f.endsWeekKey),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: RachaTokens.space2),
            TextButton(
              onPressed: () async {
                try {
                  await ref
                      .read(protectControllerProvider.notifier)
                      .cancelFreeze(f.id);
                  ref.invalidate(protectHubProvider);
                  ref.invalidate(streakProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.freezeCancelled)),
                    );
                  }
                } on ApiException catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.message)));
                  }
                }
              },
              child: Text(l10n.protectCancelFreeze),
            ),
          ],
        ),
      );
    }

    return _OptionRow(
      icon: Icons.ac_unit,
      title: l10n.protectDeclarePause,
      subtitle: hub.freezeQuotaUsed
          ? l10n.protectFreezeQuotaUsed
          : l10n.protectFreezeQuotaAvailable,
      enabled: !hub.freezeQuotaUsed,
      onTap: () async {
        await context.push('/streak/freeze/new');
        ref.invalidate(protectHubProvider);
        ref.invalidate(streakProvider);
      },
    );
  }
}

class _RepairSection extends ConsumerWidget {
  const _RepairSection({required this.hub});
  final ProtectHub hub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final r in hub.pendingRepairs)
          Card(
            margin: const EdgeInsets.only(bottom: RachaTokens.space2),
            child: ListTile(
              leading: Icon(
                r.isMine ? Icons.hourglass_empty : Icons.how_to_reg_outlined,
                color: scheme.primary,
              ),
              title: Text(
                r.isMine
                    ? l10n.protectPendingMine(r.targetWeekKey)
                    : l10n.protectPendingYours(r.targetWeekKey),
              ),
              trailing: r.isMine ? null : const Icon(Icons.chevron_right),
              onTap: r.isMine
                  ? null
                  : () async {
                      await context.push('/streak/repair/${r.id}');
                      ref.invalidate(protectHubProvider);
                      ref.invalidate(streakProvider);
                    },
            ),
          ),
        if (hub.repairAvailable)
          _OptionRow(
            icon: Icons.healing_outlined,
            title: l10n.protectSaveLastWeek,
            subtitle: l10n.protectRepairSub,
            onTap: () async {
              await context.push('/streak/repair/new');
              ref.invalidate(protectHubProvider);
              ref.invalidate(streakProvider);
            },
          ),
        if (!hub.repairAvailable &&
            hub.pendingRepairs.isEmpty &&
            hub.activeFreeze == null)
          Padding(
            padding: const EdgeInsets.only(top: RachaTokens.space3),
            child: Text(
              l10n.protectNothing,
              style: TextStyle(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
