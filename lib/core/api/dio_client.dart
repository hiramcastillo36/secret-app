import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_controller.dart';
import '../env/env.dart';
import '../i18n/locale_controller.dart';
import '../storage/token_storage.dart';

/// The configured Dio instance. One interceptor attaches the bearer token; a
/// second one refreshes it exactly once on a 401 and replays the request,
/// queueing any concurrent calls so only a single refresh is in flight.
final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(tokenStorageProvider);

  final dio = Dio(BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    contentType: Headers.jsonContentType,
  ));

  dio.interceptors.add(_AuthInterceptor(ref, dio, storage));
  return dio;
});

bool _isAuthPath(String path) => path.contains('/auth/');

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._ref, this._dio, this._storage);

  final Ref _ref;
  final Dio _dio;
  final TokenStorage _storage;

  Future<void>? _refreshing;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Every call carries the active language so the backend localizes errors,
    // emails and push text to match the UI. Independent of the refresh flow.
    options.headers['Accept-Language'] =
        resolvedLanguageTag(_ref.read(localeControllerProvider));

    if (!_isAuthPath(options.path)) {
      final access = await _storage.readAccess();
      if (access != null && access.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $access';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final isRefreshable = response?.statusCode == 401 &&
        !_isAuthPath(err.requestOptions.path) &&
        err.requestOptions.extra['__retried'] != true;

    if (!isRefreshable) {
      handler.next(err);
      return;
    }

    try {
      // Single-flight: concurrent 401s all await the same refresh future.
      _refreshing ??= _performRefresh();
      await _refreshing;
    } catch (_) {
      await _ref.read(sessionControllerProvider.notifier).signOut();
      handler.next(err);
      return;
    } finally {
      _refreshing = null;
    }

    try {
      final access = await _storage.readAccess();
      final opts = err.requestOptions
        ..extra['__retried'] = true
        ..headers['Authorization'] = 'Bearer $access';
      final retried = await _dio.fetch<dynamic>(opts);
      handler.resolve(retried);
    } catch (e) {
      handler.next(e is DioException ? e : err);
    }
  }

  Future<void> _performRefresh() async {
    final refresh = await _storage.readRefresh();
    if (refresh == null || refresh.isEmpty) {
      throw StateError('no refresh token');
    }
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refresh_token': refresh},
      options: Options(extra: {'__retried': true}),
    );
    final data = res.data!;
    await _storage.save(
      access: data['access_token'] as String,
      refresh: data['refresh_token'] as String,
    );
  }
}
