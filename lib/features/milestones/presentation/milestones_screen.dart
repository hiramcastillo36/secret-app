import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/error_retry.dart';
import '../application/milestones_controller.dart';
import '../domain/models.dart';

/// /milestones — the couple's badge ladder. The top card celebrates the most
/// recent rung; below it every rung is listed, reached ones checked and the next
/// ones showing how close they are.
class MilestonesScreen extends ConsumerWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(milestonesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.milestonesTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            ErrorRetry(onRetry: () => ref.invalidate(milestonesProvider)),
        data: (board) {
          if (board.reached.isEmpty && board.next.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(RachaTokens.space7),
                child: Text(l10n.milestonesEmpty, textAlign: TextAlign.center),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(milestonesProvider);
              await ref.read(milestonesProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.all(RachaTokens.space5),
              children: [
                if (board.reached.isNotEmpty) ...[
                  _SectionLabel(l10n.milestonesLatest),
                  const SizedBox(height: RachaTokens.space2),
                  _LatestCard(milestone: board.reached.first),
                  const SizedBox(height: RachaTokens.space6),
                ],
                _SectionLabel(l10n.milestonesAll),
                const SizedBox(height: RachaTokens.space2),
                for (final m in board.reached) _Row(milestone: m),
                for (final m in board.next) _Row(milestone: m),
              ],
            ),
          );
        },
      ),
    );
  }
}

String milestoneLabel(AppLocalizations l10n, Milestone m) => switch (m.kind) {
  MilestoneKind.dates when m.target == 1 => l10n.milestoneFirstDate,
  MilestoneKind.dates => l10n.milestoneDates(m.target),
  MilestoneKind.streakWeeks => l10n.milestoneStreak(m.target),
  MilestoneKind.daysTogether => l10n.milestoneDays(m.target),
};

IconData milestoneIcon(MilestoneKind kind) => switch (kind) {
  MilestoneKind.dates => Icons.favorite,
  MilestoneKind.streakWeeks => Icons.local_fire_department,
  MilestoneKind.daysTogether => Icons.calendar_today,
};

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: RachaType.micro,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    );
  }
}

class _LatestCard extends StatelessWidget {
  const _LatestCard({required this.milestone});
  final Milestone milestone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(RachaTokens.space5),
      decoration: BoxDecoration(
        borderRadius: RachaTokens.brL,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.primary],
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.15),
              borderRadius: RachaTokens.brM,
            ),
            child: Icon(milestoneIcon(milestone.kind), color: scheme.onPrimary),
          ),
          const SizedBox(width: RachaTokens.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestoneLabel(l10n, milestone),
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: RachaType.body,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: RachaTokens.space1),
                Text(
                  l10n.milestonesUnlocked,
                  style: TextStyle(
                    color: scheme.onPrimary.withValues(alpha: 0.6),
                    fontSize: RachaType.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.milestone});
  final Milestone milestone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final done = milestone.achieved;
    return Container(
      margin: const EdgeInsets.only(bottom: RachaTokens.space2),
      padding: const EdgeInsets.all(RachaTokens.space3),
      decoration: BoxDecoration(
        color: done
            ? scheme.surfaceContainerLow
            : scheme.surfaceContainerHighest,
        borderRadius: RachaTokens.brM,
        border: Border.all(
          color: done ? scheme.outlineVariant : Colors.transparent,
          width: RachaTokens.borderHairline,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: done ? scheme.primary : scheme.surface,
            child: Icon(
              done ? Icons.check : milestoneIcon(milestone.kind),
              size: 16,
              color: done ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: RachaTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestoneLabel(l10n, milestone),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: done ? scheme.onSurface : scheme.onSurfaceVariant,
                  ),
                ),
                if (!done) ...[
                  const SizedBox(height: RachaTokens.space1),
                  ClipRRect(
                    borderRadius: RachaTokens.brS,
                    child: LinearProgressIndicator(
                      value: milestone.progress,
                      minHeight: 6,
                      backgroundColor: scheme.surface,
                      semanticsLabel:
                          '${milestone.current} / ${milestone.target}',
                      semanticsValue: '${(milestone.progress * 100).round()}%',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${milestone.current} / ${milestone.target}',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: RachaType.micro,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
