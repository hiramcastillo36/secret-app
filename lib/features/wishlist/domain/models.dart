class WishItem {
  const WishItem({
    required this.id,
    required this.addedBy,
    required this.kind,
    required this.title,
    required this.status,
    this.placeId,
    this.placeName,
    this.placeCategory,
    this.placeLat,
    this.placeLng,
    this.note,
    this.costBand,
    this.category,
  });

  final String id;
  final String addedBy;
  final String kind; // place | idea
  final String title;
  final String status; // open | planned | done
  final String? placeId;
  final String? placeName;
  final String? placeCategory;
  final double? placeLat;
  final double? placeLng;
  final String? note;
  final String? costBand;
  final String? category;

  bool get isOpen => status == 'open';
  bool get hasLocation => placeLat != null && placeLng != null;

  factory WishItem.fromJson(Map<String, dynamic> j) => WishItem(
        id: j['id'] as String,
        addedBy: (j['added_by'] ?? '') as String,
        kind: (j['kind'] ?? 'idea') as String,
        title: (j['title'] ?? '') as String,
        status: (j['status'] ?? 'open') as String,
        placeId: j['place_id'] as String?,
        placeName: j['place_name'] as String?,
        placeCategory: j['place_category'] as String?,
        placeLat: (j['place_lat'] as num?)?.toDouble(),
        placeLng: (j['place_lng'] as num?)?.toDouble(),
        note: j['note'] as String?,
        costBand: j['cost_band'] as String?,
        category: j['category'] as String?,
      );
}

class WishCounts {
  const WishCounts({required this.open, required this.planned, required this.done});
  final int open;
  final int planned;
  final int done;

  factory WishCounts.fromJson(Map<String, dynamic>? j) => WishCounts(
        open: (j?['open'] ?? 0) as int,
        planned: (j?['planned'] ?? 0) as int,
        done: (j?['done'] ?? 0) as int,
      );
}

class WishList {
  const WishList({required this.items, required this.counts});
  final List<WishItem> items;
  final WishCounts counts;

  List<WishItem> get open => items.where((i) => i.status == 'open').toList();

  factory WishList.fromJson(Map<String, dynamic> j) => WishList(
        items: ((j['items'] as List?) ?? const [])
            .map((e) => WishItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        counts: WishCounts.fromJson((j['counts'] as Map?)?.cast<String, dynamic>()),
      );
}

class Suggestion {
  const Suggestion({
    required this.placeId,
    required this.name,
    required this.category,
    required this.reason,
  });

  final String placeId;
  final String name;
  final String category;
  final String reason;

  factory Suggestion.fromJson(Map<String, dynamic> j) => Suggestion(
        placeId: (j['place_id'] ?? '') as String,
        name: (j['name'] ?? '') as String,
        category: (j['category'] ?? 'other') as String,
        reason: (j['reason'] ?? '') as String,
      );
}
