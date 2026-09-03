import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/error_retry.dart';
import '../../common/skeleton.dart';
import '../application/privacy.dart';

/// /profile/privacy — the handful of switches that change what the app shares,
/// plus the account-level exits (export, leave couple, delete account). Each
/// switch is optimistic: it moves immediately and only snaps back if the PATCH
/// fails (audit F, medium: every switch bounced ~300ms until the refetch).
class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  final Map<String, Object> _optimistic = {};

  bool _bool(bool serverValue, String key) =>
      _optimistic[key] as bool? ?? serverValue;

  String _str(String serverValue, String key) =>
      _optimistic[key] as String? ?? serverValue;

  Future<void> _save(Map<String, Object> changes) async {
    setState(() => _optimistic.addAll(changes));
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(privacyControllerProvider.notifier).save(changes);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.isNetwork ? l10n.commonNoConnection : e.message),
          ),
        );
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
    final async = ref.watch(privacySettingsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: async.when(
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: true,
        loading: () => const SkeletonList(rows: 5, rowHeight: 56),
        error: (_, __) =>
            ErrorRetry(onRetry: () => ref.invalidate(privacySettingsProvider)),
        data: (s) => ListView(
          padding: const EdgeInsets.symmetric(vertical: RachaTokens.space3),
          children: [
            SwitchListTile.adaptive(
              value: _bool(s.requireTagConsent, 'require_tag_consent'),
              title: Text(l10n.privacyRequireTagConsent),
              subtitle: Text(l10n.privacyRequireTagConsentSub),
              isThreeLine: true,
              onChanged: (v) => _save({'require_tag_consent': v}),
            ),
            SwitchListTile.adaptive(
              value: _bool(s.shareCost, 'share_cost'),
              title: Text(l10n.privacyShareCost),
              subtitle: Text(l10n.privacyShareCostSub),
              isThreeLine: true,
              onChanged: (v) => _save({'share_cost': v}),
            ),
            SwitchListTile.adaptive(
              value:
                  _str(
                    s.notesPrivateByDefault ? 'private' : 'couple',
                    'default_notes_visibility',
                  ) ==
                  'private',
              title: Text(l10n.privacyNotesPrivate),
              subtitle: Text(l10n.privacyNotesPrivateSub),
              isThreeLine: true,
              onChanged: (v) =>
                  _save({'default_notes_visibility': v ? 'private' : 'couple'}),
            ),
            const Divider(),
            SwitchListTile.adaptive(
              value: _bool(s.analyticsOptIn, 'analytics_opt_in'),
              title: Text(l10n.privacyAnalytics),
              subtitle: Text(l10n.privacyAnalyticsSub),
              isThreeLine: true,
              onChanged: (v) => _save({'analytics_opt_in': v}),
            ),
            SwitchListTile.adaptive(
              value: _bool(s.marketingEmailsOptIn, 'marketing_emails_opt_in'),
              title: Text(l10n.privacyMarketing),
              subtitle: Text(l10n.privacyMarketingSub),
              isThreeLine: true,
              onChanged: (v) => _save({'marketing_emails_opt_in': v}),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: Text(l10n.privacyExport),
              subtitle: Text(l10n.privacyExportSub),
              onTap: () => _exportData(context, ref),
            ),
            ListTile(
              leading: Icon(Icons.link_off, color: scheme.error),
              title: Text(
                l10n.privacyLeaveCouple,
                style: TextStyle(color: scheme.error),
              ),
              onTap: () => _leaveCouple(context, ref),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: scheme.error),
              title: Text(
                l10n.accountDeleteTitle,
                style: TextStyle(color: scheme.error),
              ),
              subtitle: Text(l10n.privacyDeleteSub),
              onTap: () => context.push('/account'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(privacyControllerProvider.notifier).requestDataExport();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.privacyExportQueued)));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _leaveCouple(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(RachaTokens.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.privacyLeaveCouple,
              style: const TextStyle(
                fontSize: RachaType.headline,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: RachaTokens.space2),
            Text(
              l10n.privacyLeaveCoupleWarning,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: RachaTokens.space5),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: scheme.error),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.privacyLeaveCoupleConfirm),
            ),
            const SizedBox(height: RachaTokens.space2),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(privacyControllerProvider.notifier).leaveCouple();
      if (context.mounted) context.go('/couple/setup');
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
