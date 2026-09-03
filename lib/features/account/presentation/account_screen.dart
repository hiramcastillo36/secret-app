import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../auth/application/auth.dart';
import '../../common/error_retry.dart';
import '../../common/settings_group.dart';
import '../../common/skeleton.dart';
import '../../common/status_pill.dart';
import '../../profile/presentation/language_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(meProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: async.when(
        loading: () => const SkeletonList(rows: 5, rowHeight: 56),
        error: (_, __) => ErrorRetry(onRetry: () => ref.invalidate(meProvider)),
        data: (me) {
          final user = me.user;
          final dark = Theme.of(context).brightness == Brightness.dark;
          return ListView(
            padding: const EdgeInsets.all(RachaTokens.space5),
            children: [
              Container(
                padding: const EdgeInsets.all(RachaTokens.space4),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: RachaTokens.brM,
                  border: Border.all(
                    color: scheme.outlineVariant,
                    width: RachaTokens.borderHairline,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.accountEmail,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: RachaType.caption,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: RachaType.body,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: RachaTokens.space3),
                    Row(
                      children: [
                        StatusPill(
                          label: user.emailVerified
                              ? l10n.accountVerified
                              : l10n.accountUnverified,
                          color: user.emailVerified
                              ? (dark
                                    ? RachaTokens.okDark
                                    : RachaTokens.okLight)
                              : scheme.error,
                          icon: user.emailVerified
                              ? Icons.check
                              : Icons.error_outline,
                        ),
                        const Spacer(),
                        if (!user.emailVerified)
                          TextButton(
                            onPressed: () => context.push('/auth/verify-email'),
                            child: Text(l10n.accountVerifyNow),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: RachaTokens.space5),
              SettingsGroup(
                children: [
                  SettingsRow(
                    icon: Icons.notifications_outlined,
                    label: l10n.accountNotifications,
                    onTap: () => context.push('/profile/notifications'),
                  ),
                  SettingsRow(
                    icon: Icons.translate_outlined,
                    label: l10n.settingsLanguage,
                    value: languageLabel(
                      l10n,
                      ref.watch(localeControllerProvider),
                    ),
                    onTap: () => context.push('/profile/language'),
                  ),
                  SettingsRow(
                    icon: Icons.lock_outline,
                    label: l10n.privacyTitle,
                    onTap: () => context.push('/profile/privacy'),
                  ),
                ],
              ),
              const SizedBox(height: RachaTokens.space6),
              if (user.pendingDeletion)
                _CancelDeletionTile(onDone: () => ref.invalidate(meProvider))
              else
                _DeleteAccountTile(
                  email: user.email,
                  onScheduled: () => ref.invalidate(meProvider),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DeleteAccountTile extends ConsumerStatefulWidget {
  const _DeleteAccountTile({required this.email, required this.onScheduled});
  final String email;
  final VoidCallback onScheduled;

  @override
  ConsumerState<_DeleteAccountTile> createState() => _DeleteAccountTileState();
}

class _DeleteAccountTileState extends ConsumerState<_DeleteAccountTile> {
  bool _expanded = false;
  final _confirm = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _confirm.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_confirm.text.trim().toLowerCase() != widget.email.toLowerCase()) {
      setState(() => _error = l10n.accountDeleteConfirmLabel);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final date = await ref
          .read(authActionsProvider.notifier)
          .requestAccountDeletion(
            confirmation: _confirm.text.trim(),
            password: _password.text,
          );
      if (!mounted) return;
      final locale = Localizations.localeOf(context).toLanguageTag();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.accountDeleteScheduled(DateFormat.yMMMd(locale).format(date)),
          ),
        ),
      );
      widget.onScheduled();
    } on ApiException catch (e) {
      if (mounted) {
        setState(
          () => _error = switch (e.code) {
            'STALE_CREDENTIAL' => l10n.accountDeletePassword,
            'CONFIRMATION_MISMATCH' => l10n.accountDeleteConfirmLabel,
            'NETWORK' => l10n.commonNoConnection,
            _ => e.localizedMessage(context),
          },
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    if (!_expanded) {
      return TextButton.icon(
        onPressed: () => setState(() => _expanded = true),
        icon: Icon(Icons.delete_outline, color: scheme.error),
        label: Text(
          l10n.accountDeleteTitle,
          style: TextStyle(color: scheme.error),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: RachaTokens.space3),
      padding: const EdgeInsets.all(RachaTokens.space4),
      decoration: BoxDecoration(
        borderRadius: RachaTokens.brM,
        border: Border.all(
          color: scheme.error,
          width: RachaTokens.borderHairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.accountDeleteExplain,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: RachaTokens.space3),
          TextField(
            controller: _confirm,
            decoration: InputDecoration(
              labelText: l10n.accountDeleteConfirmLabel,
            ),
          ),
          const SizedBox(height: RachaTokens.space2),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.accountDeletePassword),
          ),
          if (_error != null) ...[
            const SizedBox(height: RachaTokens.space2),
            Text(
              _error!,
              style: TextStyle(
                color: scheme.error,
                fontSize: RachaType.caption,
              ),
            ),
          ],
          const SizedBox(height: RachaTokens.space3),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.error),
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.accountDeleteConfirm),
          ),
        ],
      ),
    );
  }
}

class _CancelDeletionTile extends ConsumerStatefulWidget {
  const _CancelDeletionTile({required this.onDone});
  final VoidCallback onDone;

  @override
  ConsumerState<_CancelDeletionTile> createState() =>
      _CancelDeletionTileState();
}

class _CancelDeletionTileState extends ConsumerState<_CancelDeletionTile> {
  bool _busy = false;

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(authActionsProvider.notifier).cancelAccountDeletion();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.accountDeletionCancelled)));
      widget.onDone();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.localizedMessage(context))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: RachaTokens.space3),
      padding: const EdgeInsets.all(RachaTokens.space4),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: RachaTokens.brM,
        border: Border.all(
          color: scheme.error,
          width: RachaTokens.borderHairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.accountDeleteBody,
            style: TextStyle(color: scheme.onErrorContainer),
          ),
          const SizedBox(height: RachaTokens.space3),
          FilledButton(
            onPressed: _busy ? null : _cancel,
            child: Text(l10n.accountCancelDeletion),
          ),
        ],
      ),
    );
  }
}
