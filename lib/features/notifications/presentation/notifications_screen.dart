import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/error_retry.dart';
import '../../common/skeleton.dart';
import '../application/notifications.dart';

/// One switch per notification type with a real example of the text, plus the
/// reminder hour and quiet-hours window.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  // Applied on top of the server value the instant a control is touched, so a
  // switch doesn't visually bounce back until the PATCH round-trips (audit F,
  // medium). Cleared per key once that key's save resolves either way.
  final Map<String, Object> _optimistic = {};

  bool _bool(bool serverValue, String key) =>
      _optimistic[key] as bool? ?? serverValue;

  int _int(int serverValue, String key) =>
      _optimistic[key] as int? ?? serverValue;

  String _str(String serverValue, String key) =>
      _optimistic[key] as String? ?? serverValue;

  Future<void> _save(Map<String, Object> changes) async {
    setState(() => _optimistic.addAll(changes));
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(notificationsControllerProvider.notifier)
          .savePreferences(changes);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.notifSaved)));
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) {
        setState(() => changes.keys.forEach(_optimistic.remove));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifTitle)),
      body: async.when(
        // Keep showing the current values while a save reloads the provider.
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: true,
        loading: () => const SkeletonList(rows: 6, rowHeight: 56),
        error: (_, __) => ErrorRetry(
          onRetry: () => ref.invalidate(notificationPreferencesProvider),
        ),
        data: (p) => ListView(
          padding: const EdgeInsets.symmetric(vertical: RachaTokens.space3),
          children: [
            SwitchListTile.adaptive(
              value: _bool(p.streakReminder, 'streak_reminder'),
              title: Text(l10n.notifStreakReminder),
              subtitle: Text(l10n.notifStreakReminderEx),
              isThreeLine: true,
              onChanged: (v) => _save({'streak_reminder': v}),
            ),
            SwitchListTile.adaptive(
              value: _bool(p.streakAdvanced, 'streak_advanced'),
              title: Text(l10n.notifStreakAdvanced),
              onChanged: (v) => _save({'streak_advanced': v}),
            ),
            SwitchListTile.adaptive(
              value: _bool(p.tagPending, 'tag_pending'),
              title: Text(l10n.notifTagPending),
              onChanged: (v) => _save({'tag_pending': v}),
            ),
            SwitchListTile.adaptive(
              value: _bool(p.partnerActivity, 'partner_activity'),
              title: Text(l10n.notifPartnerActivity),
              onChanged: (v) => _save({'partner_activity': v}),
            ),
            SwitchListTile.adaptive(
              value: _bool(p.weeklyRecap, 'weekly_recap'),
              title: Text(l10n.notifWeeklyRecap),
              onChanged: (v) => _save({'weekly_recap': v}),
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.notifReminderHour),
              trailing: DropdownButton<int>(
                value: _int(p.reminderHour, 'reminder_hour'),
                items: [
                  for (var h = 0; h < 24; h++)
                    DropdownMenuItem(
                      value: h,
                      child: Text('${h.toString().padLeft(2, '0')}:00'),
                    ),
                ],
                onChanged: (v) =>
                    v == null ? null : _save({'reminder_hour': v}),
              ),
            ),
            ListTile(
              title: Text(l10n.notifQuietHours),
              subtitle: Text(
                '${_str(p.quietHoursStart, 'quiet_hours_start')} – '
                '${_str(p.quietHoursEnd, 'quiet_hours_end')}',
              ),
              trailing: TextButton(
                onPressed: () => _editQuietHours(context, p),
                child: Text(l10n.dateDetailEdit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editQuietHours(
    BuildContext context,
    NotificationPreferences p,
  ) async {
    final l10n = AppLocalizations.of(context);
    TimeOfDay parse(String hm) {
      final parts = hm.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final start = await showTimePicker(
      context: context,
      initialTime: parse(_str(p.quietHoursStart, 'quiet_hours_start')),
      helpText: l10n.notifQuietFrom,
    );
    if (start == null || !context.mounted) return;
    final end = await showTimePicker(
      context: context,
      initialTime: parse(_str(p.quietHoursEnd, 'quiet_hours_end')),
      helpText: l10n.notifQuietTo,
    );
    if (end == null) return;
    String fmt(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    await _save({'quiet_hours_start': fmt(start), 'quiet_hours_end': fmt(end)});
  }
}
