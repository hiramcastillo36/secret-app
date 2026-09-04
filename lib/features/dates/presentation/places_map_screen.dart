import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/osm_attribution.dart';
import '../../plans/domain/models.dart';
import '../../wishlist/application/wishlist.dart';
import '../../wishlist/domain/models.dart';
import '../application/dates.dart';
import '../domain/models.dart';
import 'date_format.dart';

enum _Layer { visited, toVisit }

/// flutter_map + OpenStreetMap tiles (no Google Maps SDK). A toggle switches
/// between places already visited (pins scale with visit count) and open wishes
/// that have a location. Tapping a visited pin selects it and fills the panel at
/// the bottom; the strip of chips there jumps between places. The OSM
/// attribution is mandatory.
class PlacesMapScreen extends ConsumerStatefulWidget {
  const PlacesMapScreen({super.key});

  @override
  ConsumerState<PlacesMapScreen> createState() => _PlacesMapScreenState();
}

class _PlacesMapScreenState extends ConsumerState<PlacesMapScreen> {
  final _map = MapController();
  _Layer _layer = _Layer.visited;
  String? _selectedId;

  void _select(PlaceStat p) {
    setState(() => _selectedId = p.placeId);
    _map.move(LatLng(p.lat, p.lng), 14);
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final visited = ref.watch(summaryPlacesProvider);
    final wishes = ref.watch(wishlistProvider);

    final toVisit = (wishes.valueOrNull?.items ?? const <WishItem>[])
        .where((w) => w.status == 'open' && w.hasLocation)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mapTitle),
        actions: [
          TextButton(
            onPressed: () => context.push('/summary'),
            child: Text(l10n.mapSummary),
          ),
          TextButton(
            onPressed: () => context.push('/places/poster'),
            child: Text(l10n.mapPoster),
          ),
          const SizedBox(width: RachaTokens.space2),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(bottom: RachaTokens.space2),
            child: SegmentedButton<_Layer>(
              segments: [
                ButtonSegment(
                  value: _Layer.visited,
                  label: Text(l10n.mapLayerVisited),
                ),
                ButtonSegment(
                  value: _Layer.toVisit,
                  label: Text(l10n.mapLayerToVisit),
                ),
              ],
              selected: {_layer},
              onSelectionChanged: (s) => setState(() {
                _layer = s.first;
                _selectedId = null;
              }),
            ),
          ),
        ),
      ),
      body: visited.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (s) {
          final visitedPlaces = s.places;
          if (_layer == _Layer.visited && visitedPlaces.isEmpty) {
            return Center(
              child: Text(l10n.summaryEmpty, textAlign: TextAlign.center),
            );
          }
          if (_layer == _Layer.toVisit && toVisit.isEmpty) {
            return Center(
              child: Text(l10n.wishlistEmpty, textAlign: TextAlign.center),
            );
          }

          final maxVisits = visitedPlaces
              .map((p) => p.visits)
              .fold(1, (a, b) => a > b ? a : b);
          final center = _layer == _Layer.visited
              ? LatLng(visitedPlaces.first.lat, visitedPlaces.first.lng)
              : LatLng(toVisit.first.placeLat!, toVisit.first.placeLng!);
          PlaceStat? selected;
          if (_layer == _Layer.visited && _selectedId != null) {
            for (final p in visitedPlaces) {
              if (p.placeId == _selectedId) {
                selected = p;
                break;
              }
            }
          }

          return Column(
            children: [
              Expanded(
                child: FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 12,
                    onTap: (_, __) => setState(() => _selectedId = null),
                  ),
                  children: [
                    osmTileLayer(),
                    MarkerLayer(
                      markers: _layer == _Layer.visited
                          ? [
                              for (final p in visitedPlaces)
                                Marker(
                                  point: LatLng(p.lat, p.lng),
                                  width: 48,
                                  height: 48,
                                  child: _VisitedPin(
                                    place: p,
                                    maxVisits: maxVisits,
                                    selected: p.placeId == _selectedId,
                                    onTap: () => _select(p),
                                  ),
                                ),
                            ]
                          : [
                              for (final w in toVisit)
                                Marker(
                                  point: LatLng(w.placeLat!, w.placeLng!),
                                  width: 44,
                                  height: 44,
                                  child: GestureDetector(
                                    onTap: () => context.push(
                                      '/plans/new',
                                      extra: PlanSeed(
                                        title: w.title,
                                        placeId: w.placeId,
                                        placeName: w.placeName,
                                        wishlistItemId: w.id,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.flag_circle_outlined,
                                      color: RachaTokens.atRiskLight,
                                      size: 34,
                                    ),
                                  ),
                                ),
                            ],
                    ),
                    const OsmAttribution(),
                  ],
                ),
              ),
              if (_layer == _Layer.visited)
                _BottomPanel(
                  places: visitedPlaces,
                  selected: selected,
                  onSelect: _select,
                  onOpen: (p) => context.push('/places/${p.placeId}'),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _VisitedPin extends StatelessWidget {
  const _VisitedPin({
    required this.place,
    required this.maxVisits,
    required this.selected,
    required this.onTap,
  });

  final PlaceStat place;
  final int maxVisits;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = (20 + 20 * (place.visits / maxVisits)).toDouble();
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: selected ? size + 8 : size,
          height: selected ? size + 8 : size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? scheme.primary : scheme.primaryContainer,
            border: Border.all(
              color: selected ? scheme.onPrimary : scheme.primary,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '${place.visits}',
            style: TextStyle(
              color: selected ? scheme.onPrimary : scheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
              fontSize: RachaType.micro,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.places,
    required this.selected,
    required this.onSelect,
    required this.onOpen,
  });

  final List<PlaceStat> places;
  final PlaceStat? selected;
  final void Function(PlaceStat) onSelect;
  final void Function(PlaceStat) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: scheme.outlineVariant,
                width: RachaTokens.borderHairline,
              ),
            ),
          ),
          padding: const EdgeInsets.all(RachaTokens.space3),
          child: selected == null
              ? SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: places.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: RachaTokens.space2),
                    itemBuilder: (context, i) {
                      final p = places[i];
                      return ActionChip(
                        avatar: Icon(categoryIcon(p.category), size: 16),
                        label: Text(p.name, overflow: TextOverflow.ellipsis),
                        onPressed: () => onSelect(p),
                      );
                    },
                  ),
                )
              : Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: RachaTokens.brS,
                      ),
                      child: Icon(
                        categoryIcon(selected!.category),
                        color: scheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: RachaTokens.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selected!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            [
                              l10n.summaryVisitsCount(selected!.visits),
                              if (selected!.avgRating != null)
                                '★ ${selected!.avgRating!.toStringAsFixed(1)}',
                            ].join(' · '),
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: RachaType.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: RachaTokens.space2),
                    FilledButton(
                      onPressed: () => onOpen(selected!),
                      child: Text(l10n.mapView),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
