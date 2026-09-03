import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../application/notifications.dart';

/// One switch per notification type with a real example of the text, plus the
/// reminder hour and quiet-hours window.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(notificationPreferencesProvider);

    Future<void> save(Map<String, dynamic> changes) async {
      try {
        await ref
            .read(notificationsControllerProvider.notifier)
            .savePreferences(changes);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.notifSaved)));
        }
      } on ApiException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message)));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (p) => ListView(
          padding: const EdgeInsets.symmetric(vertical: RachaTokens.space3),
          children: [
            SwitchListTile.adaptive(
              value: p.streakReminder,
              title: Text(l10n.notifStreakReminder),
              subtitle: Text(l10n.notifStreakReminderEx),
              isThreeLine: true,
              onChanged: (v) => save({'streak_reminder': v}),
            ),
            SwitchListTile.adaptive(
              value: p.streakAdvanced,
              title: Text(l10n.notifStreakAdvanced),
              onChanged: (v) => save({'streak_advanced': v}),
            ),
            SwitchListTile.adaptive(
              value: p.tagPending,
              title: Text(l10n.notifTagPending),
              onChanged: (v) => save({'tag_pending': v}),
            ),
            SwitchListTile.adaptive(
              value: p.partnerActivity,
              title: Text(l10n.notifPartnerActivity),
              onChanged: (v) => save({'partner_activity': v}),
            ),
            SwitchListTile.adaptive(
              value: p.weeklyRecap,
              title: Text(l10n.notifWeeklyRecap),
              onChanged: (v) => save({'weekly_recap': v}),
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.notifReminderHour),
              trailing: DropdownButton<int>(
                value: p.reminderHour,
                items: [
                  for (var h = 0; h < 24; h++)
                    DropdownMenuItem(
                      value: h,
                      child: Text('${h.toString().padLeft(2, '0')}:00'),
                    ),
                ],
                onChanged: (v) => v == null ? null : save({'reminder_hour': v}),
              ),
            ),
            ListTile(
              title: Text(l10n.notifQuietHours),
              subtitle: Text('${p.quietHoursStart} – ${p.quietHoursEnd}'),
              trailing: TextButton(
                onPressed: () => _editQuietHours(context, p, save),
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
    Future<void> Function(Map<String, dynamic>) save,
  ) async {
    final l10n = AppLocalizations.of(context);
    TimeOfDay parse(String hm) {
      final parts = hm.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final start = await showTimePicker(
      context: context,
      initialTime: parse(p.quietHoursStart),
      helpText: l10n.notifQuietFrom,
    );
    if (start == null || !context.mounted) return;
    final end = await showTimePicker(
      context: context,
      initialTime: parse(p.quietHoursEnd),
      helpText: l10n.notifQuietTo,
    );
    if (end == null) return;
    String fmt(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    await save({'quiet_hours_start': fmt(start), 'quiet_hours_end': fmt(end)});
  }
}
