import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/section_label.dart';
import '../../common/step_bar.dart';
import '../application/dates.dart';
import '../domain/models.dart';
import 'date_format.dart';

/// Step 1 of 2: find a place. Search is debounced 400ms and always goes through
/// our backend (never Nominatim directly). "No place / at home" skips it; when
/// the box is empty the places the couple already knows are offered as shortcuts.
class PlaceSearchScreen extends ConsumerStatefulWidget {
  const PlaceSearchScreen({super.key});

  @override
  ConsumerState<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends ConsumerState<PlaceSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Place> _results = const [];
  bool _loading = false;
  bool _searching = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final q = value.trim();
    if (q.length < 3) {
      setState(() {
        _results = const [];
        _error = null;
        _loading = false;
        _searching = q.isNotEmpty;
      });
      return;
    }
    setState(() {
      _loading = true;
      _searching = true;
    });
    _debounce = Timer(const Duration(milliseconds: 400), () => _run(q));
  }

  Future<void> _run(String q) async {
    try {
      final res = await ref
          .read(datesControllerProvider.notifier)
          .searchPlaces(q);
      if (!mounted) return;
      setState(() {
        _results = res.results;
        _error = null;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.isNetwork
            ? AppLocalizations.of(context).dateNewOffline
            : e.message;
        _loading = false;
      });
    }
  }

  void _pick(Place? place) {
    context.push('/dates/new/details', extra: place);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final recent =
        ref.watch(summaryPlacesProvider).valueOrNull?.places ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeLogDate),
        bottom: StepBar(step: 1, total: 2, label: l10n.dateNewStep1),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                RachaTokens.space4,
                RachaTokens.space3,
                RachaTokens.space4,
                RachaTokens.space2,
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  hintText: l10n.dateNewSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: RachaTokens.space4,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ActionChip(
                  avatar: const Icon(Icons.home_outlined, size: 18),
                  label: Text(l10n.dateNewUseNoPlace),
                  onPressed: () => _pick(null),
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(RachaTokens.space4),
                child: Text(_error!, style: TextStyle(color: scheme.error)),
              ),
            const SizedBox(height: RachaTokens.space3),
            Expanded(
              child: _searching
                  ? _ResultList(
                      header: l10n.dateNewResults,
                      places: _results,
                      onPick: _pick,
                    )
                  : recent.isEmpty
                  ? const SizedBox.shrink()
                  : _ResultList(
                      header: l10n.dateNewRecent,
                      places: [
                        for (final p in recent.take(6))
                          Place(
                            id: p.placeId,
                            name: p.name,
                            category: p.category,
                            lat: p.lat,
                            lng: p.lng,
                          ),
                      ],
                      onPick: _pick,
                      trailingVisits: {
                        for (final p in recent.take(6)) p.placeId: p.visits,
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({
    required this.header,
    required this.places,
    required this.onPick,
    this.trailingVisits = const {},
  });

  final String header;
  final List<Place> places;
  final void Function(Place) onPick;
  final Map<String, int> trailingVisits;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        RachaTokens.space4,
        0,
        RachaTokens.space4,
        RachaTokens.space7,
      ),
      children: [
        SectionLabel(header),
        const SizedBox(height: RachaTokens.space2),
        for (final p in places)
          Padding(
            padding: const EdgeInsets.only(bottom: RachaTokens.space2),
            child: Material(
              color: scheme.surfaceContainerLow,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: RachaTokens.brM,
                side: BorderSide(
                  color: scheme.outlineVariant,
                  width: RachaTokens.borderHairline,
                ),
              ),
              child: ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: RachaTokens.brS,
                  ),
                  child: Icon(
                    categoryIcon(p.category),
                    size: 20,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle:
                    (p.address == null && !trailingVisits.containsKey(p.id))
                    ? null
                    : Text(
                        trailingVisits.containsKey(p.id)
                            ? l10n.summaryVisitsCount(trailingVisits[p.id]!)
                            : p.address!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                onTap: () => onPick(p),
              ),
            ),
          ),
      ],
    );
  }
}
