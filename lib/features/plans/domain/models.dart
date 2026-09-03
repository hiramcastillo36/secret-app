import '../../dates/domain/models.dart' show Place;

/// A plan: an intention to go out. It lives apart from dates and never moves the
/// streak. A plan with no [scheduledAt] is an "idea".
class Plan {
  const Plan({
    required this.id,
    required this.proposedBy,
    required this.title,
    required this.status,
    this.notes,
    this.placeId,
    this.dateEntryId,
    this.scheduledAt,
    this.hasTime = false,
    this.weekKey,
    this.responseNote,
  });

  final String id;
  final String proposedBy;
  final String title;

  /// idea | proposed | confirmed | declined | cancelled | missed | completed
  final String status;
  final String? notes;
  final String? placeId;
  final String? dateEntryId;
  final DateTime? scheduledAt;
  final bool hasTime;
  final String? weekKey;
  final String? responseNote;

  bool get isIdea => scheduledAt == null;
  bool get isPast => scheduledAt != null && scheduledAt!.isBefore(DateTime.now());
  bool get isActionable =>
      status == 'proposed' || status == 'confirmed' || status == 'idea';

  factory Plan.fromJson(Map<String, dynamic> j) => Plan(
        id: j['id'] as String,
        proposedBy: (j['proposed_by'] ?? '') as String,
        title: (j['title'] ?? '') as String,
        status: (j['status'] ?? 'idea') as String,
        notes: j['notes'] as String?,
        placeId: j['place_id'] as String?,
        dateEntryId: j['date_entry_id'] as String?,
        scheduledAt: j['scheduled_at'] == null
            ? null
            : DateTime.parse(j['scheduled_at'] as String).toLocal(),
        hasTime: (j['has_time'] ?? false) as bool,
        weekKey: j['week_key'] as String?,
        responseNote: j['response_note'] as String?,
      );
}

class PlanList {
  const PlanList({required this.plans, required this.needsResponse});
  final List<Plan> plans;
  final int needsResponse;

  factory PlanList.fromJson(Map<String, dynamic> j) => PlanList(
        plans: ((j['plans'] as List?) ?? const [])
            .map((e) => Plan.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        needsResponse: (j['needs_response'] ?? 0) as int,
      );

  /// The soonest dated, still-open plan, or null.
  Plan? get next {
    for (final p in plans) {
      if (p.scheduledAt != null &&
          !p.isPast &&
          (p.status == 'proposed' || p.status == 'confirmed')) {
        return p;
      }
    }
    return null;
  }

  List<Plan> get ideas => plans.where((p) => p.isIdea && p.status == 'idea').toList();
}

/// One entry on the calendar: a past date or an upcoming plan.
class CalendarItem {
  const CalendarItem({
    required this.kind,
    required this.id,
    required this.title,
    required this.at,
    this.placeId,
    this.status,
    this.countsForStreak,
  });

  final String kind; // "date" | "plan"
  final String id;
  final String title;
  final DateTime at;
  final String? placeId;
  final String? status;
  final bool? countsForStreak;

  bool get isPlan => kind == 'plan';

  factory CalendarItem.fromJson(Map<String, dynamic> j) => CalendarItem(
        kind: j['kind'] as String,
        id: j['id'] as String,
        title: (j['title'] ?? '') as String,
        at: DateTime.parse(j['at'] as String).toLocal(),
        placeId: j['place_id'] as String?,
        status: j['status'] as String?,
        countsForStreak: j['counts_for_streak'] as bool?,
      );
}

class CalendarWeek {
  const CalendarWeek({required this.weekKey, required this.covered, required this.planned});
  final String weekKey;
  final bool covered;
  final bool planned;

  factory CalendarWeek.fromJson(Map<String, dynamic> j) => CalendarWeek(
        weekKey: j['week_key'] as String,
        covered: (j['covered'] ?? false) as bool,
        planned: (j['planned'] ?? false) as bool,
      );
}

class Calendar {
  const Calendar({required this.itemsByDay, required this.weeks});

  /// Local YYYY-MM-DD -> items.
  final Map<String, List<CalendarItem>> itemsByDay;
  final List<CalendarWeek> weeks;

  factory Calendar.fromJson(Map<String, dynamic> j) {
    final byDay = <String, List<CalendarItem>>{};
    for (final d in (j['days'] as List?) ?? const []) {
      final m = (d as Map).cast<String, dynamic>();
      byDay[m['date'] as String] = ((m['items'] as List?) ?? const [])
          .map((e) => CalendarItem.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    }
    return Calendar(
      itemsByDay: byDay,
      weeks: ((j['weeks'] as List?) ?? const [])
          .map((e) => CalendarWeek.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  List<CalendarItem> forDay(DateTime day) =>
      itemsByDay[_key(day)] ?? const [];

  bool dayHasPastDate(DateTime day) =>
      forDay(day).any((i) => i.kind == 'date');

  bool dayHasPlan(DateTime day) => forDay(day).any((i) => i.kind == 'plan');

  static String _key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// Re-export so screens import Place from one place.
typedef PlanPlace = Place;

/// What the plan form can be pre-filled with — from a calendar day, a wish, or a
/// place on the map.
class PlanSeed {
  const PlanSeed({this.date, this.title, this.placeId, this.placeName, this.wishlistItemId});

  final DateTime? date;
  final String? title;
  final String? placeId;
  final String? placeName;
  final String? wishlistItemId;
}
