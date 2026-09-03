import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../application/auth_controller.dart';
import 'auth_error.dart';
import 'auth_hero.dart';
import 'password_meter.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    // Drop any error left over from the login screen — they share the
    // controller (audit F-H11).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(authControllerProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _passwordOk => _password.text.length >= 8;

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    final session = await ref
        .read(authControllerProvider.notifier)
        .register(
          email: _email.text.trim(),
          password: _password.text,
          displayName: _name.text.trim(),
        );
    if (!mounted || session == null) return;
    // A brand-new account has no couple: go straight into pairing.
    context.go('/couple/setup');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    final loading = state.isLoading;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHero(
              title: l10n.registerTitle,
              subtitle: l10n.registerSubtitle,
            ),
            Padding(
              padding: const EdgeInsets.all(RachaTokens.space5),
              child: Form(
                key: _formKey,
                autovalidateMode: _submitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      decoration: InputDecoration(
                        labelText: l10n.commonDisplayName,
                      ),
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? l10n.validationNameRequired
                          : null,
                    ),
                    const SizedBox(height: RachaTokens.space3),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(labelText: l10n.commonEmail),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return l10n.validationEmailRequired;
                        if (!value.contains('@') || !value.contains('.')) {
                          return l10n.validationEmailInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: RachaTokens.space3),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: l10n.commonPassword,
                        helperText: l10n.registerPasswordHint,
                      ),
                      validator: (v) => (v ?? '').length < 8
                          ? l10n.validationPasswordTooShort
                          : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    PasswordMeter(password: _password.text),
                    if (state.hasError) ...[
                      const SizedBox(height: RachaTokens.space3),
                      _ErrorBanner(text: authErrorText(l10n, state.error!)),
                    ],
                    const SizedBox(height: RachaTokens.space5),
                    FilledButton(
                      onPressed: (loading || !_passwordOk) ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.registerSubmit),
                    ),
                    const SizedBox(height: RachaTokens.space2),
                    TextButton(
                      onPressed: () => context.pushReplacement('/login'),
                      child: Text(l10n.registerHaveAccount),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(RachaTokens.space3),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: RachaTokens.brS,
        border: Border.all(
          color: scheme.error,
          width: RachaTokens.borderHairline,
        ),
      ),
      child: Text(text, style: TextStyle(color: scheme.onErrorContainer)),
    );
  }
}
