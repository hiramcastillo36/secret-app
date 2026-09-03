import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dates_repository.dart';
import '../domain/models.dart';

// Read-only providers presentation watches. datesRepositoryProvider is
// re-exported too, for the sibling application-layer controllers (milestones,
// wrapped) — never for a widget.
export '../data/dates_repository.dart'
    show
        datesRepositoryProvider,
        streakProvider,
        recentDatesProvider,
        summaryPlacesProvider,
        overviewProvider,
        dateByIdProvider,
        placeDetailProvider;

/// Date actions. Presentation calls these instead of the repository; each
/// mutation invalidates the timeline, streak and summaries it can affect.
class DatesController extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  DatesRepository get _repo => ref.read(datesRepositoryProvider);

  void _refreshFeeds() {
    ref.invalidate(recentDatesProvider);
    ref.invalidate(streakProvider);
    ref.invalidate(overviewProvider);
    ref.invalidate(summaryPlacesProvider);
  }

  Future<CreateDateResult> create({
    required String title,
    required DateTime happenedAt,
    String? placeId,
    String? notes,
    int? rating,
    double? cost,
    String? currency,
    List<String>? participantIds,
    String? idempotencyKey,
  }) async {
    final res = await _repo.create(
      title: title,
      happenedAt: happenedAt,
      placeId: placeId,
      notes: notes,
      rating: rating,
      cost: cost,
      currency: currency,
      participantIds: participantIds,
      idempotencyKey: idempotencyKey,
    );
    _refreshFeeds();
    return res;
  }

  Future<DateEntry> update(
    String id, {
    String? title,
    DateTime? happenedAt,
    String? notes,
    int? rating,
    List<String>? participantIds,
  }) async {
    final entry = await _repo.update(
      id,
      title: title,
      happenedAt: happenedAt,
      notes: notes,
      rating: rating,
      participantIds: participantIds,
    );
    _refreshFeeds();
    ref.invalidate(dateByIdProvider(id));
    return entry;
  }

  /// Returns whether the streak broke.
  Future<bool> delete(String id) async {
    final broken = await _repo.delete(id);
    _refreshFeeds();
    return broken;
  }

  /// Place autocomplete for the date form. Read-only.
  Future<PlaceSearch> searchPlaces(String q, {double? lat, double? lng}) =>
      _repo.searchPlaces(q, lat: lat, lng: lng);

  /// One page of the timeline, for the screen's own cursor paging.
  Future<DatesPage> list({String? cursor, int limit = 20, String? placeId}) =>
      _repo.list(cursor: cursor, limit: limit, placeId: placeId);
}

final datesControllerProvider =
    AutoDisposeNotifierProvider<DatesController, void>(DatesController.new);
