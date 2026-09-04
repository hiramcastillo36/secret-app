import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/locale_controller.dart';
import '../../../core/media/media_repository.dart';
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
              Center(
                child: _AvatarPicker(
                  avatarUrl: user.avatarUrl,
                  displayName: user.displayName,
                  onUploaded: () => ref.invalidate(meProvider),
                ),
              ),
              const SizedBox(height: RachaTokens.space5),
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

/// Tap the avatar to replace it: pick one image, PATCH /uploads/sign -> PUT
/// -> confirm, then PATCH /me with the new avatar_media_id.
class _AvatarPicker extends ConsumerStatefulWidget {
  const _AvatarPicker({
    required this.avatarUrl,
    required this.displayName,
    required this.onUploaded,
  });
  final String? avatarUrl;
  final String displayName;
  final VoidCallback onUploaded;

  @override
  ConsumerState<_AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends ConsumerState<_AvatarPicker> {
  bool _busy = false;

  static String _initial(String name) =>
      name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();

  Future<void> _pick() async {
    final l10n = AppLocalizations.of(context);
    XFile? file;
    try {
      file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (_) {
      return; // the platform declined — nothing to show
    }
    if (file == null || !mounted) return;

    final contentType = mediaContentTypeForPath(file.path);
    if (contentType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.photoUnsupportedType)));
      return;
    }

    setState(() => _busy = true);
    try {
      final bytes = await file.readAsBytes();
      final media = await ref
          .read(mediaRepositoryProvider)
          .upload(
            bytes: bytes,
            contentType: contentType,
            kind: MediaKind.avatar,
          );
      await ref.read(authActionsProvider.notifier).updateAvatar(media.id);
      widget.onUploaded();
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
    return Tooltip(
      message: l10n.accountChangeAvatar,
      child: InkWell(
        onTap: _busy ? null : _pick,
        customBorder: const CircleBorder(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: scheme.primaryContainer,
              backgroundImage:
                  (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)
                  ? NetworkImage(widget.avatarUrl!)
                  : null,
              child: (widget.avatarUrl == null || widget.avatarUrl!.isEmpty)
                  ? Text(
                      _initial(widget.displayName),
                      style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontSize: RachaType.title,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
            if (_busy)
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.black.withValues(alpha: 0.35),
                child: const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              )
            else
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.surface, width: 2),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
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
