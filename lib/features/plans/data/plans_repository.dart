import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/dio_client.dart';
import '../domain/models.dart';

class PlansRepository {
  PlansRepository(this._dio);
  final Dio _dio;

  Future<PlanList> list({bool includeAll = false}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/plans',
        queryParameters: includeAll ? {'include': 'all'} : null,
      );
      return PlanList.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Plan> get(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/plans/$id');
      return Plan.fromJson((res.data!['plan'] as Map).cast<String, dynamic>());
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Plan> create({
    String title = '',
    String? placeId,
    DateTime? scheduledAt,
    bool hasTime = false,
    String? notes,
    String? wishlistItemId,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>('/plans', data: {
        if (title.isNotEmpty) 'title': title,
        if (placeId != null) 'place_id': placeId,
        if (scheduledAt != null) 'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        if (scheduledAt != null) 'has_time': hasTime,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (wishlistItemId != null) 'wishlist_item_id': wishlistItemId,
      });
      return Plan.fromJson((res.data!['plan'] as Map).cast<String, dynamic>());
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Plan> patch(
    String id, {
    String? title,
    String? placeId,
    DateTime? scheduledAt,
    bool? hasTime,
    String? notes,
  }) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>('/plans/$id', data: {
        if (title != null) 'title': title,
        if (placeId != null) 'place_id': placeId,
        if (scheduledAt != null) 'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        if (hasTime != null) 'has_time': hasTime,
        if (notes != null) 'notes': notes,
      });
      return Plan.fromJson((res.data!['plan'] as Map).cast<String, dynamic>());
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// decision: "confirm" | "decline".
  Future<Plan> respond(String id, String decision, {String? note}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>('/plans/$id/respond', data: {
        'decision': decision,
        if (note != null && note.isNotEmpty) 'note': note,
      });
      return Plan.fromJson((res.data!['plan'] as Map).cast<String, dynamic>());
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Plan> cancel(String id) async {
    try {
      final res = await _dio.delete<Map<String, dynamic>>('/plans/$id');
      return Plan.fromJson((res.data!['plan'] as Map).cast<String, dynamic>());
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Turns the plan into a real date via the backend's shared POST /dates path.
  /// Returns the created date id.
  Future<String> complete(
    String id, {
    required DateTime happenedAt,
    String? title,
    String? placeId,
    int? rating,
    double? cost,
    String? notes,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>('/plans/$id/complete', data: {
        'happened_at': happenedAt.toUtc().toIso8601String(),
        if (title != null) 'title': title,
        if (placeId != null) 'place_id': placeId,
        if (rating != null) 'rating': rating,
        if (cost != null) 'cost': cost,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
      return ((res.data!['date'] as Map)['id']) as String;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Calendar> calendar({required DateTime from, required DateTime to}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/calendar', queryParameters: {
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
      });
      return Calendar.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final plansRepositoryProvider = Provider<PlansRepository>((ref) {
  return PlansRepository(ref.watch(dioProvider));
});

/// Upcoming plans + ideas, used by the calendar's Ideas tab and by Home.
final plansListProvider = FutureProvider.autoDispose<PlanList>((ref) {
  return ref.watch(plansRepositoryProvider).list();
});

final planProvider =
    FutureProvider.autoDispose.family<Plan, String>((ref, id) {
  return ref.watch(plansRepositoryProvider).get(id);
});

/// The calendar for the month containing [month] (day is ignored). Fetches a
/// window padded by a week on each side so edge days render.
final calendarProvider =
    FutureProvider.autoDispose.family<Calendar, DateTime>((ref, month) {
  final first = DateTime(month.year, month.month, 1).subtract(const Duration(days: 7));
  final last = DateTime(month.year, month.month + 1, 1).add(const Duration(days: 7));
  return ref.watch(plansRepositoryProvider).calendar(from: first, to: last);
});
