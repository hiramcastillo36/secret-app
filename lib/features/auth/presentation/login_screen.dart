import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../application/auth_controller.dart';
import 'auth_error.dart';
import 'auth_hero.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    // Drop any error left over from the register screen — they share the
    // controller (audit F-H11).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(authControllerProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    final session = await ref
        .read(authControllerProvider.notifier)
        .login(email: _email.text.trim(), password: _password.text);
    if (!mounted || session == null) return;
    // We already know from the login response whether there's a couple — no
    // need to bounce through /splash and re-run bootstrap + GET /me.
    context.go(session.coupleId != null ? '/home' : '/couple/setup');
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
            AuthHero(title: l10n.loginTitle, subtitle: l10n.loginSubtitle),
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
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: l10n.commonPassword,
                      ),
                      validator: (v) => (v ?? '').isEmpty
                          ? l10n.validationPasswordRequired
                          : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/auth/forgot-password'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: RachaTokens.space2,
                          ),
                        ),
                        child: Text(l10n.loginForgotPassword),
                      ),
                    ),
                    if (state.hasError) ...[
                      const SizedBox(height: RachaTokens.space2),
                      _ErrorBanner(text: authErrorText(l10n, state.error!)),
                    ],
                    const SizedBox(height: RachaTokens.space4),
                    FilledButton(
                      onPressed: loading ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.loginSubmit),
                    ),
                    const SizedBox(height: RachaTokens.space2),
                    TextButton(
                      onPressed: () => context.pushReplacement('/register'),
                      child: Text(l10n.loginNoAccount),
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
