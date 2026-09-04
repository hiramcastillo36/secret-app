import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/dio_client.dart';
import '../domain/models.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<AuthSession> register({
    required String email,
    required String password,
    required String displayName,
    String? timezone,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'display_name': displayName,
          if (timezone != null) 'timezone': timezone,
        },
      );
      return AuthSession.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthSession.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<MeBootstrap> me() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/me');
      return MeBootstrap.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post<void>('/auth/password/forgot', data: {'email': email});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _dio.post<void>(
        '/auth/password/reset',
        data: {'token': token, 'new_password': newPassword},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Returns retry_after seconds.
  Future<int> sendEmailVerification() async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/email/verify/send',
      );
      return (res.data?['retry_after'] ?? 60) as int;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> verifyEmail(String token) async {
    try {
      await _dio.post<void>('/auth/email/verify', data: {'token': token});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Returns the scheduled deletion date.
  Future<DateTime> requestAccountDeletion({
    required String confirmation,
    String? password,
    String? reason,
  }) async {
    try {
      final res = await _dio.delete<Map<String, dynamic>>(
        '/me',
        data: {
          'confirmation': confirmation,
          if (password != null && password.isNotEmpty) 'password': password,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
      return DateTime.parse(res.data!['scheduled_for'] as String);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> cancelAccountDeletion() async {
    try {
      await _dio.post<void>('/me/deletion/cancel');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// PATCH /me — sets the avatar to an already-confirmed media id (see
  /// MediaRepository.upload). Returns the updated user so the caller can
  /// refresh its cache.
  Future<AppUser> updateAvatar(String mediaId) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        '/me',
        data: {'avatar_media_id': mediaId},
      );
      return AppUser.fromJson(
        (res.data!['user'] as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// PATCH /me/locale — persists the language for messages sent outside a
  /// request (reminder emails, weekly recap, push), where there is no
  /// Accept-Language header to negotiate from. Best effort, like [logout]:
  /// every request already carries Accept-Language via the dio interceptor,
  /// so a failure here only delays those out-of-band messages catching up.
  Future<void> updateLocale(String locale) async {
    try {
      await _dio.patch<void>('/me/locale', data: {'locale': locale});
    } on DioException catch (_) {
      // ignore: best effort, see doc comment above
    }
  }

  /// Revokes the refresh token server-side. Best effort — local sign-out
  /// proceeds regardless — so a failure is swallowed rather than thrown.
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<void>(
        '/auth/logout',
        data: {'refresh_token': refreshToken},
      );
    } on DioException catch (_) {
      // ignore: the caller clears local state anyway
    }
  }
}

/// The bootstrap payload for Home banners; refreshed on demand.
final meProvider = FutureProvider.autoDispose<MeBootstrap>((ref) {
  return ref.watch(authRepositoryProvider).me();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});
