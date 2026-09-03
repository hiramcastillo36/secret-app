import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notifications_repository.dart';

// The models and read-only providers presentation needs. The repository itself
// (and its provider) stay hidden — screens go through the controller.
export '../data/notifications_repository.dart'
    show
        NotificationPreferences,
        AppNotification,
        NotificationsPage,
        notificationPreferencesProvider,
        activityFeedProvider,
        unreadNotificationsProvider;

/// Notification-centre actions. Presentation calls these instead of touching the
/// repository, and each one invalidates the read providers it affects.
class NotificationsController extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  NotificationsRepository get _repo =>
      ref.read(notificationsRepositoryProvider);

  Future<NotificationPreferences> savePreferences(
    Map<String, dynamic> changes,
  ) async {
    final updated = await _repo.patch(changes);
    ref.invalidate(notificationPreferencesProvider);
    return updated;
  }

  /// One page of the activity feed, for the screen's own cursor paging.
  Future<NotificationsPage> history({String? cursor, int limit = 20}) =>
      _repo.history(cursor: cursor, limit: limit);

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    ref.invalidate(unreadNotificationsProvider);
    ref.invalidate(activityFeedProvider);
  }
}

final notificationsControllerProvider =
    AutoDisposeNotifierProvider<NotificationsController, void>(
      NotificationsController.new,
    );
