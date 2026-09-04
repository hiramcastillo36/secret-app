import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/dio_client.dart';
import '../domain/models.dart';

class WishlistRepository {
  WishlistRepository(this._dio);
  final Dio _dio;

  Future<WishList> list({String? status, String? kind}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/wishlist',
        queryParameters: {
          if (status != null) 'status': status,
          if (kind != null) 'kind': kind,
        },
      );
      return WishList.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<WishItem> create({
    required String title,
    String? placeId,
    String? note,
    String? costBand,
    String? category,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/wishlist',
        data: {
          'title': title,
          if (placeId != null) 'place_id': placeId,
          if (note != null && note.isNotEmpty) 'note': note,
          if (costBand != null) 'cost_band': costBand,
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );
      return WishItem.fromJson(
        (res.data!['item'] as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<WishItem> patch(
    String id, {
    String? title,
    String? note,
    String? status,
  }) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        '/wishlist/$id',
        data: {
          if (title != null) 'title': title,
          if (note != null) 'note': note,
          if (status != null) 'status': status,
        },
      );
      return WishItem.fromJson(
        (res.data!['item'] as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> delete(String id, {bool force = false}) async {
    try {
      await _dio.delete<void>(
        '/wishlist/$id',
        queryParameters: force ? {'force': 'true'} : null,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /wishlist/pick — one open wish at random. Throws ApiException with
  /// code 'wishlist_empty' when nothing matches.
  Future<WishItem> pick({bool cheap = false, String? category}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/wishlist/pick',
        data: {
          'cheap': cheap,
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );
      return WishItem.fromJson(
        (res.data!['item'] as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<Suggestion>> suggestions({bool cheap = false}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/suggestions',
        queryParameters: cheap ? {'cheap': 'true'} : null,
      );
      return ((res.data!['suggestions'] as List?) ?? const [])
          .map((e) => Suggestion.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository(ref.watch(dioProvider));
});

final wishlistProvider = FutureProvider.autoDispose<WishList>((ref) {
  return ref.watch(wishlistRepositoryProvider).list();
});

final suggestionsProvider = FutureProvider.autoDispose
    .family<List<Suggestion>, bool>((ref, cheap) {
      return ref.watch(wishlistRepositoryProvider).suggestions(cheap: cheap);
    });
