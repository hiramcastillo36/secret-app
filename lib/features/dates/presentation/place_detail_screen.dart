import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../data/dates_repository.dart';
import '../domain/models.dart';
import 'date_format.dart';

/// /places/:id — everything the couple has done at one place: a header with the
/// running totals, then the dates logged there. "Log a date here" jumps straight
/// to the details step with the place pre-filled.
class PlaceDetailScreen extends ConsumerWidget {
  const PlaceDetailScreen({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(placeDetailProvider(placeId));

    return Scaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (data) {
          final stat = data.stat;
          final dates = data.dates;
          final firstPlace = dates.isEmpty ? null : dates.first.place;
          final name = stat?.name ?? firstPlace?.name ?? l10n.placeDetailUnknown;
          final category = stat?.category ?? firstPlace?.category ?? 'other';

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(placeDetailProvider(placeId));
              await ref.read(placeDetailProvider(placeId).future);
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 220,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(
                      left: RachaTokens.space5,
                      bottom: RachaTokens.space4,
                      right: RachaTokens.space5,
                    ),
                    title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    background: _Header(name: name, category: category, stat: stat),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(RachaTokens.space5),
                  sliver: SliverList.list(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.placeDetailDatesHere,
                            style: const TextStyle(
                                fontSize: RachaType.headline, fontWeight: FontWeight.w700)),
                        TextButton.icon(
                          onPressed: () => context.push(
                            '/dates/new/details',
                            extra: stat == null
                                ? null
                                : Place(
                                    id: stat.placeId,
                                    name: stat.name,
                                    category: stat.category,
                                    lat: stat.lat,
                                    lng: stat.lng,
                                  ),
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.placeDetailLogHere),
                        ),
                      ],
                    ),
                    const SizedBox(height: RachaTokens.space3),
                    if (dates.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: RachaTokens.space6),
                        child: Center(child: Text(l10n.placeDetailEmpty)),
                      )
                    else
                      for (final d in dates) _DateRow(date: d),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.category, required this.stat});
  final String name;
  final String category;
  final PlaceStat? stat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.primary],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
          RachaTokens.space5, RachaTokens.space7, RachaTokens.space5, RachaTokens.space6),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Row(children: [
              Icon(categoryIcon(category), color: scheme.onPrimary),
              const SizedBox(width: RachaTokens.space2),
              Text(category,
                  style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.8))),
            ]),
            const SizedBox(height: RachaTokens.space3),
            if (stat != null)
              Row(children: [
                _Stat(value: '${stat!.visits}', label: l10n.placeDetailVisits),
                _Stat(
                  value: stat!.avgRating == null ? '—' : stat!.avgRating!.toStringAsFixed(1),
                  label: l10n.placeDetailRating,
                ),
                _Stat(
                  value: stat!.totalCost > 0 ? '\$${stat!.totalCost.toStringAsFixed(0)}' : '—',
                  label: l10n.placeDetailTotalCost,
                ),
              ]),
          ],
        ),
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  color: scheme.onPrimary,
                  fontSize: RachaType.headline,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: TextStyle(
                  color: scheme.onPrimary.withValues(alpha: 0.7),
                  fontSize: RachaType.caption)),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.date});
  final DateEntry date;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: RachaTokens.space2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: RachaTokens.brM,
        border: Border.all(color: scheme.outlineVariant, width: RachaTokens.borderHairline),
      ),
      child: ListTile(
        shape: const RoundedRectangleBorder(borderRadius: RachaTokens.brM),
        title: Text(date.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(relativeDay(context, date.happenedAt)),
        trailing: date.rating == null
            ? null
            : Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.star, size: 14),
                Text(' ${date.rating}'),
              ]),
        onTap: () => context.push('/dates/${date.id}'),
      ),
    );
  }
}
