import 'package:dio/dio.dart';

/// A typed view of the backend's uniform error envelope:
/// `{ "error": { "code": "...", "message": "...", "details": {...} } }`.
///
/// [code] is the stable contract the UI switches on; [message] is already
/// localized by the server and is a safe fallback to show.
class ApiException implements Exception {
  ApiException({
    required this.code,
    required this.message,
    this.status,
    this.details,
    this.isNetwork = false,
  });

  final String code;
  final String message;
  final int? status;
  final Object? details;
  final bool isNetwork;

  factory ApiException.fromDio(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException(
        code: 'NETWORK',
        message: 'Sin conexión.',
        isNetwork: true,
      );
    }
    final data = e.response?.data;
    if (data is Map && data['error'] is Map) {
      final err = (data['error'] as Map).cast<String, dynamic>();
      return ApiException(
        code: (err['code'] ?? 'UNKNOWN').toString(),
        message: (err['message'] ?? 'Algo salió mal.').toString(),
        status: e.response?.statusCode,
        details: err['details'],
      );
    }
    return ApiException(
      code: 'UNKNOWN',
      message: 'Algo salió mal.',
      status: e.response?.statusCode,
    );
  }

  @override
  String toString() => 'ApiException($code, $status): $message';
}
