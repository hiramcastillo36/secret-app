import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/section_label.dart';
import '../data/plans_repository.dart';
import '../domain/models.dart';

/// /calendar — a month of dates (plum dots, already happened) and plans (amber
/// dots, upcoming). The selected day opens below. A second tab lists ideas —
/// things to do that have no date yet. The current week's row is tinted so you
/// can see at a glance whether it's covered.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _month; // first of month
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _selected = DateTime(now.year, now.month, now.day);
  }

  void _shiftMonth(int by) {
    setState(() => _month = DateTime(_month.year, _month.month + by, 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.calendarTitle),
          bottom: TabBar(tabs: [
            Tab(text: l10n.calendarTabMonth),
            Tab(text: l10n.calendarTabIdeas),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/plans/new'),
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            _MonthTab(
              month: _month,
              selected: _selected,
              onSelect: (d) => setState(() => _selected = d),
              onShiftMonth: _shiftMonth,
            ),
            const _IdeasTab(),
          ],
        ),
      ),
    );
  }
}

class _MonthTab extends ConsumerWidget {
  const _MonthTab({
    required this.month,
    required this.selected,
    required this.onSelect,
    required this.onShiftMonth,
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<int> onShiftMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(calendarProvider(month));

    return Column(
      children: [
        _MonthHeader(month: month, onShift: onShiftMonth),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text(l10n.commonSomethingWentWrong)),
            data: (cal) => ListView(
              children: [
                _MonthGrid(
                  month: month,
                  selected: selected,
                  calendar: cal,
                  onSelect: onSelect,
                ),
                const _Legend(),
                const Divider(height: 1),
                _DayDetail(day: selected, items: cal.forDay(selected)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.month, required this.onShift});
  final DateTime month;
  final ValueChanged<int> onShift;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final label = toBeginningOfSentenceCase(DateFormat.yMMMM(locale).format(month));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RachaTokens.space3, vertical: RachaTokens.space2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filledTonal(
              onPressed: () => onShift(-1), icon: const Icon(Icons.chevron_left)),
          Text(label, style: const TextStyle(fontSize: RachaType.headline, fontWeight: FontWeight.w700)),
          IconButton.filledTonal(
              onPressed: () => onShift(1), icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    Widget item(Widget mark, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            mark,
            const SizedBox(width: RachaTokens.space1),
            Text(label,
                style: TextStyle(
                    color: scheme.onSurfaceVariant, fontSize: RachaType.caption)),
          ],
        );

    Widget dot(Color c) =>
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: c));

    return Padding(
      padding: const EdgeInsets.fromLTRB(RachaTokens.space4, RachaTokens.space2,
          RachaTokens.space4, RachaTokens.space2),
      child: Wrap(
        spacing: RachaTokens.space4,
        runSpacing: RachaTokens.space2,
        children: [
          item(dot(scheme.primary), l10n.calendarLegendDate),
          item(dot(RachaTokens.atRiskLight), l10n.calendarLegendPlan),
          item(
            Container(
              width: 16,
              height: 8,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: RachaTokens.brS,
              ),
            ),
            l10n.calendarLegendWeek,
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.calendar,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final Calendar calendar;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();

    // Grid starts on the Monday of the week containing the 1st.
    final first = DateTime(month.year, month.month, 1);
    final start = first.subtract(Duration(days: (first.weekday - DateTime.monday) % 7));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final (weekStart, weekEnd) = _isoWeekBounds(today);
    final currentWeekCovered = _weekHasCoveredDate(calendar, weekStart, weekEnd);
    final currentWeekPlanned = _weekHasPlan(calendar, weekStart, weekEnd);

    final weekdayLabels = _weekdayInitials(locale);

    return Padding(
      padding: const EdgeInsets.all(RachaTokens.space3),
      child: Column(
        children: [
          Row(
            children: [
              for (final w in weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(w,
                        style: TextStyle(
                            fontSize: RachaType.micro,
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: RachaTokens.space1),
          for (var row = 0; row < 6; row++)
            _WeekRow(
              days: [for (var col = 0; col < 7; col++) start.add(Duration(days: row * 7 + col))],
              month: month,
              selected: selected,
              today: today,
              calendar: calendar,
              onSelect: onSelect,
              isCurrentWeek: (d) => !d.isBefore(weekStart) && !d.isAfter(weekEnd),
              currentWeekCovered: currentWeekCovered,
              currentWeekPlanned: currentWeekPlanned,
            ),
        ],
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.days,
    required this.month,
    required this.selected,
    required this.today,
    required this.calendar,
    required this.onSelect,
    required this.isCurrentWeek,
    required this.currentWeekCovered,
    required this.currentWeekPlanned,
  });

  final List<DateTime> days;
  final DateTime month;
  final DateTime selected;
  final DateTime today;
  final Calendar calendar;
  final ValueChanged<DateTime> onSelect;
  final bool Function(DateTime) isCurrentWeek;
  final bool currentWeekCovered;
  final bool currentWeekPlanned;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final highlightThisWeek = days.any(isCurrentWeek);

    Color? rowBg;
    if (highlightThisWeek) {
      rowBg = currentWeekCovered
          ? scheme.primaryContainer.withValues(alpha: 0.5)
          : currentWeekPlanned
              ? RachaTokens.atRiskDark.withValues(alpha: 0.18)
              : scheme.surfaceContainerHighest;
    }

    return Container(
      decoration: BoxDecoration(color: rowBg, borderRadius: RachaTokens.brS),
      child: Row(
        children: [
          for (final d in days)
            Expanded(
              child: _DayCell(
                day: d,
                inMonth: d.month == month.month,
                isToday: _sameDay(d, today),
                isSelected: _sameDay(d, selected),
                hasDate: calendar.dayHasPastDate(d),
                hasPlan: calendar.dayHasPlan(d),
                onTap: () => onSelect(DateTime(d.year, d.month, d.day)),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.hasDate,
    required this.hasPlan,
    required this.onTap,
  });

  final DateTime day;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final bool hasDate;
  final bool hasPlan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color dayColor = isSelected
        ? scheme.onPrimary
        : !inMonth
            ? scheme.onSurfaceVariant.withValues(alpha: 0.5)
            : isToday
                ? scheme.primary
                : scheme.onSurface;
    final dotColor = isSelected ? scheme.onPrimary : null;

    return InkWell(
      onTap: onTap,
      borderRadius: RachaTokens.brS,
      child: Container(
        height: 44,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: RachaTokens.brS,
          color: isSelected
              ? scheme.primary
              : isToday
                  ? scheme.primary.withValues(alpha: 0.12)
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: RachaType.caption,
                fontWeight: (isToday || isSelected) ? FontWeight.w800 : FontWeight.w500,
                color: dayColor,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasDate) _dot(dotColor ?? scheme.primary),
                if (hasDate && hasPlan) const SizedBox(width: 3),
                if (hasPlan) _dot(dotColor ?? RachaTokens.atRiskLight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c) =>
      Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: c));
}

class _DayDetail extends StatelessWidget {
  const _DayDetail({required this.day, required this.items});
  final DateTime day;
  final List<CalendarItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final heading = toBeginningOfSentenceCase(DateFormat.MMMMEEEEd(locale).format(day));

    return Padding(
      padding: const EdgeInsets.all(RachaTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(heading, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: RachaTokens.space2),
          if (items.isEmpty) ...[
            Text(l10n.calendarDayEmpty, style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: RachaTokens.space2),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/plans/new', extra: day),
                icon: const Icon(Icons.add),
                label: Text(l10n.calendarPlanHere),
              ),
            ),
          ] else
            for (final it in items) _ItemTile(item: it),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});
  final CalendarItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPlan = item.isPlan;
    final accent = isPlan ? RachaTokens.atRiskLight : scheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: RachaTokens.space2),
      child: Material(
        color: scheme.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: RachaTokens.brM,
          side: BorderSide(color: scheme.outlineVariant, width: RachaTokens.borderHairline),
        ),
        child: InkWell(
          onTap: () => context.push(isPlan ? '/plans/${item.id}' : '/dates/${item.id}'),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: accent),
                const SizedBox(width: RachaTokens.space3),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: RachaTokens.space3),
                  child: Icon(isPlan ? Icons.event_outlined : Icons.favorite,
                      size: 18, color: accent),
                ),
                const SizedBox(width: RachaTokens.space3),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: RachaTokens.space3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(TimeOfDay.fromDateTime(item.at).format(context),
                            style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: RachaType.caption)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: RachaTokens.space2),
                  child: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IdeasTab extends ConsumerWidget {
  const _IdeasTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(plansListProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(child: Text(l10n.commonSomethingWentWrong)),
      data: (list) {
        final ideas = list.ideas;
        return ListView(
          padding: const EdgeInsets.all(RachaTokens.space4),
          children: [
            SectionLabel(
              l10n.calendarIdeasNoDate,
              trailing: TextButton.icon(
                onPressed: () => context.push('/plans/new'),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.calendarAdd),
              ),
            ),
            const SizedBox(height: RachaTokens.space2),
            if (ideas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: RachaTokens.space7),
                child: Center(child: Text(l10n.calendarNoIdeas, textAlign: TextAlign.center)),
              )
            else
              for (final idea in ideas)
                Padding(
                  padding: const EdgeInsets.only(bottom: RachaTokens.space2),
                  child: Material(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: RachaTokens.brM,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: RachaTokens.borderHairline),
                    ),
                    child: InkWell(
                      onTap: () => context.push('/plans/${idea.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(RachaTokens.space3),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline,
                                color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: RachaTokens.space3),
                            Expanded(
                              child: Text(idea.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: RachaTokens.space2),
                            FilledButton.tonal(
                              onPressed: () => context.push('/plans/${idea.id}'),
                              child: Text(l10n.calendarPlanIt),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

// --- helpers ---

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

(DateTime, DateTime) _isoWeekBounds(DateTime day) {
  final d = DateTime(day.year, day.month, day.day);
  final monday = d.subtract(Duration(days: (d.weekday - DateTime.monday) % 7));
  return (monday, monday.add(const Duration(days: 6)));
}

bool _weekHasCoveredDate(Calendar cal, DateTime start, DateTime end) {
  for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
    if (cal.forDay(d).any((i) => i.kind == 'date' && (i.countsForStreak ?? false))) {
      return true;
    }
  }
  return false;
}

bool _weekHasPlan(Calendar cal, DateTime start, DateTime end) {
  for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
    if (cal.forDay(d).any((i) => i.kind == 'plan')) return true;
  }
  return false;
}

List<String> _weekdayInitials(String locale) {
  final base = DateTime(2024, 1, 1); // a Monday
  return [
    for (var i = 0; i < 7; i++)
      DateFormat.E(locale).format(base.add(Duration(days: i))).characters.first.toUpperCase(),
  ];
}
