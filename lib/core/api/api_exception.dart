import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

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
      // No server message to lean on — the empty message is filled in by
      // [localizedMessage] (audit F, medium: this was a fixed Spanish string
      // shown inside an otherwise-English UI).
      return ApiException(code: 'NETWORK', message: '', isNetwork: true);
    }
    final data = e.response?.data;
    if (data is Map && data['error'] is Map) {
      final err = (data['error'] as Map).cast<String, dynamic>();
      return ApiException(
        code: (err['code'] ?? 'UNKNOWN').toString(),
        message: (err['message'] ?? '').toString(),
        status: e.response?.statusCode,
        details: err['details'],
      );
    }
    return ApiException(
      code: 'UNKNOWN',
      message: '',
      status: e.response?.statusCode,
    );
  }

  /// The message to show a user: the server's localized [message] when there is
  /// one, otherwise a localized fallback for the offline / unknown cases.
  String localizedMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (isNetwork) return l10n.commonNoConnection;
    if (message.trim().isEmpty) return l10n.commonSomethingWentWrong;
    return message;
  }

  @override
  String toString() => 'ApiException($code, $status): $message';
}
