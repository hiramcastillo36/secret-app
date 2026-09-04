// Plain models for the dates + streak feature.

class Place {
  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.lat,
    required this.lng,
    this.address,
    this.osmType,
    this.osmId,
    this.city,
    this.country,
  });

  final String id;
  final String name;
  final String category;
  final double lat;
  final double lng;
  final String? address;
  final String? osmType;
  final String? osmId;
  final String? city;
  final String? country;

  factory Place.fromJson(Map<String, dynamic> j) => Place(
    id: (j['id'] ?? '') as String,
    name: j['name'] as String,
    category: (j['category'] ?? 'other') as String,
    lat: (j['lat'] as num).toDouble(),
    lng: (j['lng'] as num).toDouble(),
    address: j['address'] as String?,
    osmType: j['osm_type'] as String?,
    osmId: j['osm_id'] as String?,
    city: j['city'] as String?,
    country: j['country'] as String?,
  );
}

class PlaceSearch {
  const PlaceSearch({required this.results, required this.source});
  final List<Place> results;
  final String source;

  factory PlaceSearch.fromJson(Map<String, dynamic> j) => PlaceSearch(
    results: ((j['results'] as List?) ?? const [])
        .map((e) => Place.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
    source: (j['source'] ?? 'cache') as String,
  );
}

class DateParticipant {
  const DateParticipant({
    required this.userId,
    required this.displayName,
    required this.status,
  });
  final String userId;
  final String displayName;
  final String status;

  factory DateParticipant.fromJson(Map<String, dynamic> j) => DateParticipant(
    userId: j['user_id'] as String,
    displayName: j['display_name'] as String,
    status: (j['status'] ?? 'confirmed') as String,
  );
}

/// A photo attached to a date. [url] and [thumbUrl] are signed and expire —
/// fetch a fresh [DateEntry] rather than caching them.
class DatePhoto {
  const DatePhoto({
    required this.id,
    required this.url,
    this.thumbUrl,
    this.blurhash,
    this.position = 0,
  });
  final String id;
  final String url;
  final String? thumbUrl;
  final String? blurhash;
  final int position;

  factory DatePhoto.fromJson(Map<String, dynamic> j) => DatePhoto(
    id: (j['id'] ?? '') as String,
    url: (j['url'] ?? '') as String,
    thumbUrl: j['thumb_url'] as String?,
    blurhash: j['blurhash'] as String?,
    position: (j['position'] as num?)?.toInt() ?? 0,
  );
}

class DateEntry {
  const DateEntry({
    required this.id,
    required this.title,
    required this.happenedAt,
    required this.weekKey,
    required this.countsForStreak,
    required this.participants,
    this.place,
    this.notes,
    this.rating,
    this.cost,
    this.currency = 'MXN',
    this.photos = const [],
  });

  final String id;
  final String title;
  final DateTime happenedAt;
  final String weekKey;
  final bool countsForStreak;
  final List<DateParticipant> participants;
  final Place? place;
  final String? notes;
  final int? rating;
  final double? cost;
  final String currency;
  final List<DatePhoto> photos;

  factory DateEntry.fromJson(Map<String, dynamic> j) => DateEntry(
    id: j['id'] as String,
    title: j['title'] as String,
    happenedAt: DateTime.parse(j['happened_at'] as String),
    weekKey: j['week_key'] as String,
    countsForStreak: (j['counts_for_streak'] ?? false) as bool,
    participants: ((j['participants'] as List?) ?? const [])
        .map(
          (e) => DateParticipant.fromJson((e as Map).cast<String, dynamic>()),
        )
        .toList(),
    place: j['place'] == null
        ? null
        : Place.fromJson((j['place'] as Map).cast<String, dynamic>()),
    notes: j['notes'] as String?,
    rating: j['rating'] as int?,
    cost: (j['cost'] as num?)?.toDouble(),
    currency: (j['currency'] ?? 'MXN') as String,
    photos: ((j['photos'] as List?) ?? const [])
        .map((e) => DatePhoto.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
  );
}

class DatesPage {
  const DatesPage({required this.dates, this.nextCursor});
  final List<DateEntry> dates;
  final String? nextCursor;

  factory DatesPage.fromJson(Map<String, dynamic> j) => DatesPage(
    dates: ((j['dates'] as List?) ?? const [])
        .map((e) => DateEntry.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
    nextCursor: j['next_cursor'] as String?,
  );
}

class CreateDateResult {
  const CreateDateResult({required this.date, required this.streakAdvanced});
  final DateEntry date;
  final bool streakAdvanced;

  factory CreateDateResult.fromJson(Map<String, dynamic> j) => CreateDateResult(
    date: DateEntry.fromJson((j['date'] as Map).cast<String, dynamic>()),
    streakAdvanced: (j['streak_advanced'] ?? false) as bool,
  );
}

class PlaceStat {
  const PlaceStat({
    required this.placeId,
    required this.name,
    required this.category,
    required this.lat,
    required this.lng,
    required this.visits,
    this.avgRating,
    this.costByCurrency = const {},
    this.firstVisit,
    this.lastVisit,
  });

  final String placeId;
  final String name;
  final String category;
  final double lat;
  final double lng;
  final int visits;
  final double? avgRating;
  final Map<String, String> costByCurrency;
  final DateTime? firstVisit;
  final DateTime? lastVisit;

  factory PlaceStat.fromJson(Map<String, dynamic> j) => PlaceStat(
    placeId: j['place_id'] as String,
    name: j['name'] as String,
    category: (j['category'] ?? 'other') as String,
    lat: (j['lat'] as num).toDouble(),
    lng: (j['lng'] as num).toDouble(),
    visits: (j['visits'] ?? 0) as int,
    avgRating: (j['avg_rating'] as num?)?.toDouble(),
    costByCurrency: _costMap(j['cost_by_currency']),
    firstVisit: j['first_visit_at'] == null
        ? null
        : DateTime.parse(j['first_visit_at'] as String),
    lastVisit: j['last_visit_at'] == null
        ? null
        : DateTime.parse(j['last_visit_at'] as String),
  );
}

class CategoryStat {
  const CategoryStat({
    required this.category,
    required this.visits,
    required this.percentage,
  });
  final String category;
  final int visits;
  final double percentage;

  factory CategoryStat.fromJson(Map<String, dynamic> j) => CategoryStat(
    category: (j['category'] ?? 'other') as String,
    visits: (j['visits'] ?? 0) as int,
    percentage: (j['percentage'] as num?)?.toDouble() ?? 0,
  );
}

class PlacesSummary {
  const PlacesSummary({
    required this.places,
    required this.byCategory,
    required this.distinctPlaces,
    required this.totalVisits,
    required this.costByCurrency,
    this.favoritePlace,
  });

  final List<PlaceStat> places;
  final List<CategoryStat> byCategory;
  final int distinctPlaces;
  final int totalVisits;
  final Map<String, String> costByCurrency;
  final String? favoritePlace;

  bool get isEmpty => places.isEmpty;

  factory PlacesSummary.fromJson(Map<String, dynamic> j) {
    final totals = (j['totals'] as Map?)?.cast<String, dynamic>() ?? const {};
    return PlacesSummary(
      places: ((j['places'] as List?) ?? const [])
          .map((e) => PlaceStat.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      byCategory: ((j['by_category'] as List?) ?? const [])
          .map((e) => CategoryStat.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      distinctPlaces: (totals['distinct_places'] ?? 0) as int,
      totalVisits: (totals['total_visits'] ?? 0) as int,
      costByCurrency: _costMap(totals['cost_by_currency']),
      favoritePlace: totals['favorite_place'] as String?,
    );
  }
}

class Overview {
  const Overview({
    required this.totalDates,
    required this.currentStreak,
    required this.longestStreak,
    required this.distinctPlaces,
    required this.costByCurrency,
    required this.daysTogether,
    required this.datesByMonth,
    this.bestMonth,
  });

  final int totalDates;
  final int currentStreak;
  final int longestStreak;
  final int distinctPlaces;
  final Map<String, String> costByCurrency;
  final int daysTogether;
  final List<({String month, int count})> datesByMonth;
  final String? bestMonth;

  factory Overview.fromJson(Map<String, dynamic> j) => Overview(
    totalDates: (j['total_dates'] ?? 0) as int,
    currentStreak: (j['current_streak'] ?? 0) as int,
    longestStreak: (j['longest_streak'] ?? 0) as int,
    distinctPlaces: (j['distinct_places'] ?? 0) as int,
    costByCurrency: _costMap(j['cost_by_currency']),
    daysTogether: (j['days_together'] ?? 0) as int,
    bestMonth: j['best_month'] as String?,
    datesByMonth: ((j['dates_by_month'] as List?) ?? const [])
        .map(
          (e) => (
            month: ((e as Map)['month'] ?? '') as String,
            count: (e['count'] ?? 0) as int,
          ),
        )
        .toList(),
  );
}

enum WeekStatus { covered, atRisk, open, frozen }

/// Progress of the season in progress (E16). A season resets its [best] on
/// rollover or a streak break; the all-time record lives on StreakView.
class SeasonInfo {
  const SeasonInfo({
    required this.length,
    required this.best,
    this.startedOn,
    this.endsOn,
  });

  final String length; // monthly | quarterly | infinite
  final int best;
  final String? startedOn;
  final String? endsOn;

  factory SeasonInfo.fromJson(Map<String, dynamic>? j) => SeasonInfo(
    length: (j?['length'] ?? 'monthly') as String,
    best: (j?['best'] ?? 0) as int,
    startedOn: j?['started_on'] as String?,
    endsOn: j?['ends_on'] as String?,
  );
}

class StreakView {
  const StreakView({
    required this.currentStreak,
    required this.longestStreak,
    required this.recordStreak,
    required this.weekStatus,
    required this.expiresAt,
    required this.recentWeeks,
    required this.recentFrozen,
    required this.season,
  });

  final int currentStreak;
  final int longestStreak;
  final int recordStreak;
  final WeekStatus weekStatus;
  final DateTime expiresAt;
  final List<bool> recentWeeks; // oldest first, covered
  final List<bool> recentFrozen; // oldest first, aligned with recentWeeks
  final SeasonInfo season;

  bool get isFrozen => weekStatus == WeekStatus.frozen;

  int get daysLeft {
    final d = expiresAt.difference(DateTime.now()).inHours / 24;
    return d.ceil().clamp(0, 7);
  }

  factory StreakView.fromJson(Map<String, dynamic> j) {
    final weeks = ((j['recent_weeks'] as List?) ?? const [])
        .cast<Map<String, dynamic>>();
    return StreakView(
      currentStreak: (j['current_streak'] ?? 0) as int,
      longestStreak: (j['longest_streak'] ?? 0) as int,
      recordStreak: (j['record_streak'] ?? j['longest_streak'] ?? 0) as int,
      weekStatus: switch (j['week_status']) {
        'covered' => WeekStatus.covered,
        'at_risk' => WeekStatus.atRisk,
        'frozen' => WeekStatus.frozen,
        _ => WeekStatus.open,
      },
      expiresAt: DateTime.parse(j['expires_at'] as String),
      recentWeeks: weeks.map((e) => (e['covered'] ?? false) as bool).toList(),
      recentFrozen: weeks.map((e) => (e['frozen'] ?? false) as bool).toList(),
      season: SeasonInfo.fromJson(
        (j['season'] as Map?)?.cast<String, dynamic>(),
      ),
    );
  }
}

/// Parses a `{currency: "amount"}` JSON object into a typed map.
Map<String, String> _costMap(Object? raw) {
  if (raw is Map) {
    return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
  }
  return const {};
}
