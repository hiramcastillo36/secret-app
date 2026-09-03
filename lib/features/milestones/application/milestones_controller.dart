import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dates/application/dates.dart';
import '../domain/models.dart';

/// The fixed milestone ladder, resolved against the current overview numbers.
/// [reached] is newest-first (the most recent rung first); [next] is the first
/// unreached rung of each kind, in ladder order.
typedef MilestoneBoard = ({List<Milestone> reached, List<Milestone> next});

const _dateTargets = [1, 10, 25, 50, 100, 200, 365];
const _streakTargets = [4, 12, 26, 52, 78];
const _daysTargets = [30, 100, 365, 730, 1825];

final milestonesProvider = FutureProvider.autoDispose<MilestoneBoard>((
  ref,
) async {
  final ov = await ref.watch(datesRepositoryProvider).summaryOverview();

  final all = <Milestone>[
    for (final t in _dateTargets)
      Milestone(kind: MilestoneKind.dates, target: t, current: ov.totalDates),
    for (final t in _streakTargets)
      Milestone(
        kind: MilestoneKind.streakWeeks,
        target: t,
        // A rung counts as reached once the best-ever streak passed it.
        current: ov.longestStreak,
      ),
    for (final t in _daysTargets)
      Milestone(
        kind: MilestoneKind.daysTogether,
        target: t,
        current: ov.daysTogether,
      ),
  ];

  final reached = all.where((m) => m.achieved).toList()
    ..sort((a, b) => b.target.compareTo(a.target));

  final next = <Milestone>[
    for (final kind in MilestoneKind.values)
      ...() {
        final rung = all
            .where((m) => m.kind == kind && !m.achieved)
            .fold<Milestone?>(
              null,
              (min, m) => min == null || m.target < min.target ? m : min,
            );
        return rung == null ? const <Milestone>[] : [rung];
      }(),
  ]..sort((a, b) => b.progress.compareTo(a.progress));

  return (reached: reached, next: next);
});
