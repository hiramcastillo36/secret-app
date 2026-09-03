import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/dio_client.dart';
import '../domain/models.dart';

class CoupleRepository {
  CoupleRepository(this._dio);

  final Dio _dio;

  Future<Couple> create({required String name, String? timezone}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/couples',
        data: {
          'name': name,
          if (timezone != null && timezone.isNotEmpty) 'timezone': timezone,
        },
      );
      return Couple.fromJson(
        (res.data!['couple'] as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<JoinResult> join(String inviteCode) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/couples/join',
        data: {'invite_code': inviteCode},
      );
      return JoinResult.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CoupleView> me() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/couples/me');
      return CoupleView.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// PATCH /couples/me — change the couple name and/or its IANA timezone
  /// (the server recalculates the streak against the new week boundaries).
  Future<Couple> updateSettings({String? name, String? timezone}) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        '/couples/me',
        data: {
          if (name != null && name.isNotEmpty) 'name': name,
          if (timezone != null && timezone.isNotEmpty) 'timezone': timezone,
        },
      );
      return Couple.fromJson(
        (res.data!['couple'] as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final coupleRepositoryProvider = Provider<CoupleRepository>((ref) {
  return CoupleRepository(ref.watch(dioProvider));
});

/// Polled by the waiting room. `autoDispose` so polling stops when the screen
/// leaves.
final coupleMeProvider = FutureProvider.autoDispose<CoupleView>((ref) async {
  return ref.watch(coupleRepositoryProvider).me();
});
