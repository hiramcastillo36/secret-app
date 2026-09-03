import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/dio_client.dart';

/// Per-user privacy switches. Mirrors the backend `privacy_settings` row served
/// by `GET/PATCH /me/privacy`. Changes take effect from now on — turning on
/// [requireTagConsent] never rewrites past dates — except [shareCost], which the
/// server applies to every date the person ever logged.
class PrivacySettings {
  const PrivacySettings({
    required this.requireTagConsent,
    required this.shareCost,
    required this.defaultNotesVisibility,
    required this.analyticsOptIn,
    required this.marketingEmailsOptIn,
  });

  final bool requireTagConsent;
  final bool shareCost;
  final String defaultNotesVisibility; // couple | private
  final bool analyticsOptIn;
  final bool marketingEmailsOptIn;

  bool get notesPrivateByDefault => defaultNotesVisibility == 'private';

  factory PrivacySettings.fromJson(Map<String, dynamic> j) => PrivacySettings(
    requireTagConsent: (j['require_tag_consent'] ?? false) as bool,
    shareCost: (j['share_cost'] ?? true) as bool,
    defaultNotesVisibility:
        (j['default_notes_visibility'] ?? 'couple') as String,
    analyticsOptIn: (j['analytics_opt_in'] ?? false) as bool,
    marketingEmailsOptIn: (j['marketing_emails_opt_in'] ?? false) as bool,
  );
}

class PrivacyRepository {
  PrivacyRepository(this._dio);
  final Dio _dio;

  Future<PrivacySettings> get() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/me/privacy');
      return PrivacySettings.fromJson(
        (res.data!['privacy'] as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// PATCH /me/privacy — only the keys present in [changes] are touched.
  Future<PrivacySettings> patch(Map<String, dynamic> changes) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        '/me/privacy',
        data: changes,
      );
      return PrivacySettings.fromJson(
        (res.data!['privacy'] as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /me/export — the server queues a data export and emails a link. Returns
  /// nothing useful beyond "accepted".
  Future<void> requestDataExport() async {
    try {
      await _dio.get<Map<String, dynamic>>('/me/export');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /couples/me/leave — leaves the couple. The streak history stays with
  /// the couple; this device drops back to the pairing fork.
  Future<void> leaveCouple() async {
    try {
      await _dio.post<void>('/couples/me/leave');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final privacyRepositoryProvider = Provider<PrivacyRepository>((ref) {
  return PrivacyRepository(ref.watch(dioProvider));
});

final privacySettingsProvider = FutureProvider.autoDispose<PrivacySettings>((
  ref,
) {
  return ref.watch(privacyRepositoryProvider).get();
});
