import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dates/data/dates_repository.dart';
import '../../dates/domain/models.dart';

typedef WrappedData = ({int year, Overview overview, PlacesSummary places});

/// Everything the "year in review" needs, for one calendar year, from the two
/// summary endpoints. No new backend: `/summary/overview?year=` already scopes
/// the totals and `/summary/places?from&to` scopes the place + category rows.
final wrappedProvider =
    FutureProvider.autoDispose.family<WrappedData, int>((ref, year) async {
  final repo = ref.watch(datesRepositoryProvider);
  final from = DateTime.utc(year);
  final to = DateTime.utc(year + 1).subtract(const Duration(seconds: 1));
  final (overview, places) = await (
    repo.summaryOverview(year: year),
    repo.summaryPlaces(from: from, to: to),
  ).wait;
  return (year: year, overview: overview, places: places);
});

/// The year the recap opens on: the current one.
int defaultWrappedYear() => DateTime.now().year;
