import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/dio_client.dart';
import '../domain/models.dart';

class DatesRepository {
  DatesRepository(this._dio);
  final Dio _dio;

  Future<StreakView> streak() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/streaks/me');
      return StreakView.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PlaceSearch> searchPlaces(String q, {double? lat, double? lng}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/places/search',
        queryParameters: {
          'q': q,
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
        },
      );
      return PlaceSearch.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<DatesPage> list({
    String? cursor,
    int limit = 20,
    String? placeId,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/dates',
        queryParameters: {
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
          if (placeId != null) 'place_id': placeId,
        },
      );
      return DatesPage.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<DateEntry> get(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/dates/$id');
      return DateEntry.fromJson(
        (res.data!['date'] as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
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
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/dates',
        data: {
          'title': title,
          'happened_at': happenedAt.toUtc().toIso8601String(),
          if (placeId != null) 'place_id': placeId,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          if (rating != null) 'rating': rating,
          if (cost != null) 'cost': cost,
          if (currency != null) 'currency': currency,
          if (participantIds != null) 'participant_ids': participantIds,
        },
        options: Options(
          headers: {
            if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
          },
        ),
      );
      return CreateDateResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<DateEntry> update(
    String id, {
    String? title,
    DateTime? happenedAt,
    String? notes,
    int? rating,
    List<String>? participantIds,
  }) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        '/dates/$id',
        data: {
          if (title != null) 'title': title,
          if (happenedAt != null)
            'happened_at': happenedAt.toUtc().toIso8601String(),
          if (notes != null) 'notes': notes,
          if (rating != null) 'rating': rating,
          if (participantIds != null) 'participant_ids': participantIds,
        },
      );
      return DateEntry.fromJson(
        (res.data!['date'] as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<bool> delete(String id) async {
    try {
      final res = await _dio.delete<Map<String, dynamic>>('/dates/$id');
      return (res.data?['streak_broken'] ?? false) as bool;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PlacesSummary> summaryPlaces({
    String sort = 'visits',
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/summary/places',
        queryParameters: {
          'sort': sort,
          if (from != null) 'from': from.toUtc().toIso8601String(),
          if (to != null) 'to': to.toUtc().toIso8601String(),
        },
      );
      return PlacesSummary.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Overview> summaryOverview({int? year}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/summary/overview',
        queryParameters: {if (year != null) 'year': year},
      );
      return Overview.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final datesRepositoryProvider = Provider<DatesRepository>((ref) {
  return DatesRepository(ref.watch(dioProvider));
});

/// The home streak card; refreshed after logging a date.
final streakProvider = FutureProvider.autoDispose<StreakView>((ref) {
  return ref.watch(datesRepositoryProvider).streak();
});

/// The last few dates shown on home.
final recentDatesProvider = FutureProvider.autoDispose<DatesPage>((ref) {
  return ref.watch(datesRepositoryProvider).list(limit: 3);
});

final summaryPlacesProvider = FutureProvider.autoDispose<PlacesSummary>((ref) {
  return ref.watch(datesRepositoryProvider).summaryPlaces();
});

final overviewProvider = FutureProvider.autoDispose<Overview>((ref) {
  return ref.watch(datesRepositoryProvider).summaryOverview();
});

final dateByIdProvider = FutureProvider.autoDispose.family<DateEntry, String>((
  ref,
  id,
) {
  return ref.watch(datesRepositoryProvider).get(id);
});

/// One place seen through the couple's history: its aggregate row from
/// `/summary/places` plus every date logged there. There is no dedicated
/// place-detail endpoint, so this composes the two reads the app already has.
final placeDetailProvider = FutureProvider.autoDispose
    .family<({PlaceStat? stat, List<DateEntry> dates}), String>((
      ref,
      placeId,
    ) async {
      final repo = ref.watch(datesRepositoryProvider);
      final (summary, page) = await (
        repo.summaryPlaces(),
        repo.list(placeId: placeId, limit: 50),
      ).wait;
      PlaceStat? stat;
      for (final p in summary.places) {
        if (p.placeId == placeId) {
          stat = p;
          break;
        }
      }
      return (stat: stat, dates: page.dates);
    });
