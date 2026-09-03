import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/field_tile.dart';
import '../application/auth.dart';

/// Opened from the email link (`/auth/verify-email?token=...`) — auto-verifies —
/// or from an in-app banner, where the user can resend and paste the code.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, this.token});
  final String? token;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _code = TextEditingController();
  int _cooldown = 0;
  Timer? _timer;
  String? _message;
  bool _busy = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    if (widget.token != null && widget.token!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _verify(widget.token!),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    setState(() => _cooldown = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  Future<void> _resend() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final retryAfter = await ref
          .read(authActionsProvider.notifier)
          .sendEmailVerification();
      if (!mounted) return;
      setState(() => _message = l10n.verifySent);
      _startCooldown(retryAfter);
    } on ApiException catch (e) {
      if (mounted) setState(() => _message = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify(String token) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(authActionsProvider.notifier).verifyEmail(token.trim());
      if (!mounted) return;
      setState(() {
        _done = true;
        _message = l10n.verifyDone;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _message = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final email = ref.watch(meProvider).valueOrNull?.user.email ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RachaTokens.space5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: RachaTokens.space4),
              Center(
                child: Container(
                  height: 88,
                  width: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primaryContainer,
                  ),
                  child: Icon(
                    _done ? Icons.mark_email_read_outlined : Icons.mail_outline,
                    size: 40,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: RachaTokens.space5),
              Text(
                l10n.verifyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: RachaType.headline,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: RachaTokens.space2),
              Text(
                l10n.verifyBody(email),
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              if (_message != null) ...[
                const SizedBox(height: RachaTokens.space3),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: RachaTokens.space5),
              if (_done)
                FilledButton(
                  onPressed: () => context.go('/home'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(l10n.commonContinue),
                )
              else ...[
                OutlinedButton(
                  onPressed: (_busy || _cooldown > 0) ? null : _resend,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    _cooldown > 0
                        ? l10n.verifyResendIn(_cooldown)
                        : l10n.verifyResend,
                  ),
                ),
                const SizedBox(height: RachaTokens.space4),
                TextField(
                  controller: _code,
                  decoration: InputDecoration(labelText: l10n.verifyManual),
                ),
                const SizedBox(height: RachaTokens.space3),
                FilledButton(
                  onPressed: _busy ? null : () => _verify(_code.text),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(l10n.verifyConfirm),
                ),
                const SizedBox(height: RachaTokens.space2),
                TextButton(
                  onPressed: () => context.go('/couple/setup'),
                  child: Text(l10n.verifyAlreadyDone),
                ),
                const SizedBox(height: RachaTokens.space4),
                NoteBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.verifyBlockedTitle,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: RachaTokens.space2),
                      _Bullet(l10n.verifyBlocked1),
                      _Bullet(l10n.verifyBlocked2),
                      _Bullet(l10n.verifyBlocked3),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: RachaTokens.space2),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: RachaType.caption,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
