import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/dio_client.dart';

class NotificationPreferences {
  const NotificationPreferences({
    required this.streakReminder,
    required this.streakAdvanced,
    required this.tagPending,
    required this.partnerActivity,
    required this.weeklyRecap,
    required this.reminderHour,
    required this.quietHoursStart,
    required this.quietHoursEnd,
  });

  final bool streakReminder;
  final bool streakAdvanced;
  final bool tagPending;
  final bool partnerActivity;
  final bool weeklyRecap;
  final int reminderHour;
  final String quietHoursStart;
  final String quietHoursEnd;

  factory NotificationPreferences.fromJson(Map<String, dynamic> j) => NotificationPreferences(
        streakReminder: (j['streak_reminder'] ?? true) as bool,
        streakAdvanced: (j['streak_advanced'] ?? true) as bool,
        tagPending: (j['tag_pending'] ?? true) as bool,
        partnerActivity: (j['partner_activity'] ?? true) as bool,
        weeklyRecap: (j['weekly_recap'] ?? true) as bool,
        reminderHour: (j['reminder_hour'] ?? 10) as int,
        quietHoursStart: (j['quiet_hours_start'] ?? '22:00') as String,
        quietHoursEnd: (j['quiet_hours_end'] ?? '08:00') as String,
      );
}

/// One row of the in-app notification centre. Title and body are rendered by the
/// backend in the request's language, so they already match the current UI.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.route,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String kind;
  final String title;
  final String body;
  final String route;
  final bool read;
  final DateTime createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        kind: (j['kind'] ?? '') as String,
        title: (j['title'] ?? '') as String,
        body: (j['body'] ?? '') as String,
        route: (j['route'] ?? '/home') as String,
        read: (j['read'] ?? false) as bool,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class NotificationsPage {
  const NotificationsPage({required this.items, required this.nextCursor, required this.unread});

  final List<AppNotification> items;
  final String? nextCursor;
  final int unread;
}

class NotificationsRepository {
  NotificationsRepository(this._dio);
  final Dio _dio;

  /// GET /me/notifications — newest first, cursor-paginated.
  Future<NotificationsPage> history({String? cursor, int limit = 20}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/me/notifications',
        queryParameters: {
          'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
      );
      final data = res.data!;
      final items = (data['items'] as List? ?? const [])
          .map((e) => AppNotification.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
      final next = data['next_cursor'] as String?;
      return NotificationsPage(
        items: items,
        nextCursor: (next == null || next.isEmpty) ? null : next,
        unread: (data['unread'] ?? 0) as int,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /me/notifications/read — marks every unread row read. Returns the
  /// remaining unread count (0).
  Future<int> markAllRead() async {
    try {
      final res = await _dio.post<Map<String, dynamic>>('/me/notifications/read');
      return (res.data?['unread'] ?? 0) as int;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<NotificationPreferences> get() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/me/notifications/preferences');
      return NotificationPreferences.fromJson(
          (res.data!['preferences'] as Map).cast<String, dynamic>());
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<NotificationPreferences> patch(Map<String, dynamic> changes) async {
    try {
      final res =
          await _dio.patch<Map<String, dynamic>>('/me/notifications/preferences', data: changes);
      return NotificationPreferences.fromJson(
          (res.data!['preferences'] as Map).cast<String, dynamic>());
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(dioProvider));
});

final notificationPreferencesProvider =
    FutureProvider.autoDispose<NotificationPreferences>((ref) {
  return ref.watch(notificationsRepositoryProvider).get();
});

/// First page of the activity feed. The activity screen watches this and pages
/// further with the repository directly.
final activityFeedProvider = FutureProvider.autoDispose<NotificationsPage>((ref) {
  return ref.watch(notificationsRepositoryProvider).history();
});

/// Unread badge count for the Home app bar. Cheap: asks for a single row.
final unreadNotificationsProvider = FutureProvider.autoDispose<int>((ref) async {
  final page = await ref.watch(notificationsRepositoryProvider).history(limit: 1);
  return page.unread;
});
