import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/error_banner.dart';
import '../../common/field_tile.dart';
import '../data/auth_repository.dart';
import 'password_meter.dart';

/// Reached from the email link (`/auth/reset-password?token=...`) or opened
/// manually with the code pasted in.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.token});
  final String? token;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final TextEditingController _token;
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  bool _done = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _token = TextEditingController(text: widget.token ?? '');
  }

  @override
  void dispose() {
    _token.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _password.text.length >= 8 && _password.text == _confirm.text;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_token.text.trim().isEmpty || _password.text.length < 8) {
      setState(() => _error = l10n.validationPasswordTooShort);
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() => _error = l10n.resetMismatch);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            token: _token.text.trim(),
            newPassword: _password.text,
          );
      if (mounted) setState(() => _done = true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = switch (e.code) {
              'INVALID_TOKEN' => l10n.resetInvalidToken,
              'NETWORK' => l10n.commonNoConnection,
              _ => e.message,
            });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resetTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RachaTokens.space5),
          child: _done
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.resetDone, style: TextStyle(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: RachaTokens.space5),
                    FilledButton(
                      onPressed: () => context.go('/login'),
                      child: Text(l10n.loginSubmit),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NoteBox(
                      tone: 'warning',
                      icon: Icons.warning_amber_rounded,
                      child: Text(l10n.resetWarning),
                    ),
                    const SizedBox(height: RachaTokens.space4),
                    if (widget.token == null) ...[
                      TextField(
                        controller: _token,
                        decoration: InputDecoration(labelText: l10n.resetTokenLabel),
                      ),
                      const SizedBox(height: RachaTokens.space3),
                    ],
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(labelText: l10n.resetNewPassword),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: RachaTokens.space3),
                    TextField(
                      controller: _confirm,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.resetConfirmLabel,
                        errorText: (_confirm.text.isNotEmpty &&
                                _confirm.text != _password.text)
                            ? l10n.resetMismatch
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: RachaTokens.space4),
                    PasswordRequirements(password: _password.text),
                    if (_error != null) ...[
                      const SizedBox(height: RachaTokens.space3),
                      ErrorBanner(text: _error!),
                    ],
                    const SizedBox(height: RachaTokens.space5),
                    FilledButton(
                      onPressed: (_saving || !_canSubmit) ? null : _submit,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      child: _saving
                          ? const SizedBox(
                              height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.resetSubmit),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
