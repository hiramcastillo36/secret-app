import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../data/dates_repository.dart';
import '../domain/models.dart';
import 'date_format.dart';

/// Where we've been: totals, a category breakdown and the ordered place list.
class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(summaryPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.summaryTitle),
        actions: [
          IconButton(
            onPressed: () => context.push('/places/map'),
            icon: const Icon(Icons.map_outlined),
            tooltip: l10n.summaryOpenMap,
          ),
          IconButton(
            onPressed: () => context.push('/places/poster'),
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.posterTitle,
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (s) => s.isEmpty
            ? _Empty(text: l10n.summaryEmpty)
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(summaryPlacesProvider);
                  await ref.read(summaryPlacesProvider.future);
                },
                child: ListView(
                  padding: const EdgeInsets.all(RachaTokens.space5),
                  children: [
                    _TotalsRow(summary: s),
                    if (s.favoritePlace != null) ...[
                      const SizedBox(height: RachaTokens.space3),
                      Text(l10n.summaryFavorite(s.favoritePlace!),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: RachaTokens.space6),
                    Text(l10n.summaryByCategory,
                        style: const TextStyle(fontSize: RachaType.headline, fontWeight: FontWeight.w700)),
                    const SizedBox(height: RachaTokens.space3),
                    for (final c in s.byCategory) _CategoryBar(stat: c),
                    const SizedBox(height: RachaTokens.space6),
                    for (final p in s.places) _PlaceTile(stat: p),
                  ],
                ),
              ),
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.summary});
  final PlacesSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        _Stat(value: '${summary.distinctPlaces}', label: l10n.summaryDistinctPlaces),
        _Stat(value: '${summary.totalVisits}', label: l10n.summaryTotalVisits),
        _Stat(value: '\$${summary.totalCost.toStringAsFixed(0)}', label: l10n.summaryTotalCost),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: RachaType.headline, fontWeight: FontWeight.w800)),
          Text(label, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: RachaType.caption)),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.stat});
  final CategoryStat stat;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: RachaTokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(categoryIcon(stat.category), size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: RachaTokens.space2),
                Text(stat.category),
              ]),
              Text('${stat.percentage.round()}%',
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: RachaTokens.space1),
          ClipRRect(
            borderRadius: RachaTokens.brS,
            child: LinearProgressIndicator(
              value: (stat.percentage / 100).clamp(0, 1),
              minHeight: 8,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({required this.stat});
  final PlaceStat stat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: RachaTokens.space2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: RachaTokens.brM,
        border: Border.all(color: scheme.outlineVariant, width: RachaTokens.borderHairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: stat.placeId.isEmpty ? null : () => context.push('/places/${stat.placeId}'),
        child: Padding(
          padding: const EdgeInsets.all(RachaTokens.space3),
          child: Row(
            children: [
              Icon(categoryIcon(stat.category), color: scheme.onSurfaceVariant),
              const SizedBox(width: RachaTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(l10n.summaryVisitsCount(stat.visits),
                        style: TextStyle(
                            color: scheme.onSurfaceVariant, fontSize: RachaType.caption)),
                  ],
                ),
              ),
              if (stat.avgRating != null)
                Row(children: [
                  const Icon(Icons.star, size: 14),
                  Text(' ${stat.avgRating!.toStringAsFixed(1)}'),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(RachaTokens.space7),
          child: Text(text, textAlign: TextAlign.center),
        ),
      );
}
