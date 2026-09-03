import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/format/money.dart';
import '../../../theme/tokens.dart';
import '../application/dates.dart';
import '../domain/models.dart';
import 'date_format.dart';

/// The full timeline, newest first, paginated by opaque cursor. A search box
/// filters the rows already loaded (there is no server-side query); each entry
/// sits on a left rail so the sequence reads as one thread.
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();
  final List<DateEntry> _dates = [];
  String? _cursor;
  bool _loading = false;
  bool _done = false;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
    _loadMore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _done) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await ref
          .read(datesControllerProvider.notifier)
          .list(cursor: _cursor, limit: 20);
      if (!mounted) return;
      setState(() {
        _dates.addAll(page.dates);
        _cursor = page.nextCursor;
        _done = page.nextCursor == null;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.isNetwork
            ? AppLocalizations.of(context).commonNoConnection
            : e.message;
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _dates.clear();
      _cursor = null;
      _done = false;
    });
    await _loadMore();
  }

  List<DateEntry> get _visible {
    if (_query.isEmpty) return _dates;
    final q = _query.toLowerCase();
    return _dates
        .where(
          (d) =>
              d.title.toLowerCase().contains(q) ||
              (d.place?.name.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final visible = _visible;
    final showEmpty = visible.isEmpty && (_done || _query.isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.timelineTitle),
        actions: [
          if (_dates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: RachaTokens.space4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RachaTokens.space3,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(RachaTokens.radiusFull),
                  ),
                  child: Text(
                    l10n.timelineCount(_dates.length) + (_done ? '' : '+'),
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontSize: RachaType.caption,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              RachaTokens.space4,
              0,
              RachaTokens.space4,
              RachaTokens.space3,
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                isDense: true,
                hintText: l10n.timelineSearchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.a11yClearSearch,
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: showEmpty
            ? ListView(
                children: [
                  const SizedBox(height: RachaTokens.space7),
                  Center(
                    child: Text(
                      _query.isEmpty
                          ? l10n.timelineEmpty
                          : l10n.timelineNoMatch,
                    ),
                  ),
                  if (_query.isNotEmpty)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        child: Text(l10n.timelineClearSearch),
                      ),
                    ),
                ],
              )
            : ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(
                  RachaTokens.space4,
                  RachaTokens.space4,
                  RachaTokens.space4,
                  RachaTokens.space7 + RachaTokens.space5,
                ),
                itemCount: visible.length + 1,
                itemBuilder: (context, i) {
                  if (i == visible.length) {
                    if (_error != null) {
                      return Padding(
                        padding: const EdgeInsets.all(RachaTokens.space4),
                        child: Column(
                          children: [
                            Text(_error!),
                            TextButton(
                              onPressed: _loadMore,
                              child: Text(l10n.commonRetry),
                            ),
                          ],
                        ),
                      );
                    }
                    if (_loading && _query.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(RachaTokens.space5),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return const SizedBox.shrink();
                  }
                  return _TimelineRow(
                    date: visible[i],
                    isLast: i == visible.length - 1,
                  );
                },
              ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.date, required this.isLast});
  final DateEntry date;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left rail: node + connector.
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: RachaTokens.space5),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary,
                    border: Border.all(
                      color: scheme.primaryContainer,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: RachaTokens.borderHairline,
                      color: scheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: RachaTokens.space2),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: RachaTokens.space4),
              child: _TimelineCard(date: date),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.date});
  final DateEntry date;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: RachaTokens.brM,
        side: BorderSide(
          color: scheme.outlineVariant,
          width: RachaTokens.borderHairline,
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/dates/${date.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header strip stands in for the photo the design shows.
            Container(
              height: 56,
              width: double.infinity,
              color: scheme.primaryContainer,
              padding: const EdgeInsets.symmetric(
                horizontal: RachaTokens.space3,
              ),
              child: Row(
                children: [
                  Icon(
                    categoryIcon(date.place?.category ?? 'other'),
                    color: scheme.onPrimaryContainer,
                  ),
                  const Spacer(),
                  for (final p in date.participants.take(3))
                    Padding(
                      padding: const EdgeInsets.only(left: RachaTokens.space1),
                      child: CircleAvatar(
                        radius: 11,
                        backgroundColor: scheme.surface,
                        child: Text(
                          _initial(p.displayName),
                          style: TextStyle(
                            fontSize: RachaType.micro,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(RachaTokens.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              date.title,
                              style: const TextStyle(
                                fontSize: RachaType.body,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (date.place != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    size: 12,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      date.place!.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: scheme.onSurfaceVariant,
                                        fontSize: RachaType.caption,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: RachaTokens.space2),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            relativeDay(context, date.happenedAt),
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: RachaType.caption,
                            ),
                          ),
                          if (date.rating != null) ...[
                            const SizedBox(height: 2),
                            _Stars(rating: date.rating!),
                          ],
                        ],
                      ),
                    ],
                  ),
                  if (date.cost != null) ...[
                    const SizedBox(height: RachaTokens.space2),
                    Text(
                      formatMoney(
                        date.cost,
                        date.currency,
                        locale: Localizations.localeOf(context).toString(),
                      ),
                      style: const TextStyle(
                        fontSize: RachaType.caption,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (!date.countsForStreak) ...[
                    const SizedBox(height: RachaTokens.space2),
                    Row(
                      children: [
                        Icon(
                          Icons.link_off,
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.timelineDoesntCount,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: RachaType.micro,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _initial(String name) =>
      name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});
  final int rating;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var n = 1; n <= 5; n++)
          Icon(
            n <= rating ? Icons.star : Icons.star_border,
            size: 14,
            color: n <= rating ? scheme.primary : scheme.outlineVariant,
          ),
      ],
    );
  }
}
