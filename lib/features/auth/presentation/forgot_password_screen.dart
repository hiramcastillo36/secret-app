import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/error_banner.dart';
import '../../common/field_tile.dart';
import '../application/auth.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sending = false;
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final value = _email.text.trim();
    if (!value.contains('@') || !value.contains('.')) {
      setState(() => _error = l10n.validationEmailInvalid);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(authActionsProvider.notifier).forgotPassword(value);
      if (mounted) setState(() => _done = true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(
          () => _error = e.isNetwork
              ? l10n.commonNoConnection
              : e.localizedMessage(context),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.forgotTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RachaTokens.space5),
          child: _done
              ? Column(
                  children: [
                    const SizedBox(height: RachaTokens.space6),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            (Theme.of(context).brightness == Brightness.dark
                                    ? RachaTokens.okDark
                                    : RachaTokens.okLight)
                                .withValues(alpha: 0.15),
                      ),
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        size: 36,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? RachaTokens.okDark
                            : RachaTokens.okLight,
                      ),
                    ),
                    const SizedBox(height: RachaTokens.space5),
                    Text(
                      l10n.forgotDoneTitle,
                      style: const TextStyle(
                        fontSize: RachaType.headline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: RachaTokens.space2),
                    Text(
                      l10n.forgotDone,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.forgotBody,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: RachaTokens.space4),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: l10n.commonEmail),
                      onSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: RachaTokens.space3),
                      ErrorBanner(text: _error!),
                    ],
                    const SizedBox(height: RachaTokens.space5),
                    FilledButton(
                      onPressed: _sending ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: _sending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.forgotSubmit),
                    ),
                    const SizedBox(height: RachaTokens.space4),
                    NoteBox(
                      icon: Icons.info_outline,
                      child: Text(l10n.forgotOauthNote),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
