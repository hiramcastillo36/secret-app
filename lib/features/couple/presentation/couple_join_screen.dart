import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/error_banner.dart';
import '../application/couple_controller.dart';
import 'couple_error.dart';

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue _, TextEditingValue next) {
    return next.copyWith(text: next.text.toUpperCase());
  }
}

class CoupleJoinScreen extends ConsumerStatefulWidget {
  const CoupleJoinScreen({super.key});

  @override
  ConsumerState<CoupleJoinScreen> createState() => _CoupleJoinScreenState();
}

class _CoupleJoinScreenState extends ConsumerState<CoupleJoinScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  bool get _complete => _code.text.trim().length == 6;

  Future<void> _submit() async {
    if (!_complete) return;
    final result = await ref
        .read(coupleControllerProvider.notifier)
        .join(_code.text.trim());
    if (!mounted || result == null) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.coupleJoinWelcome(result.partner.displayName)),
      ),
    );
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(coupleControllerProvider);
    final loading = state.isLoading;

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.coupleJoinTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(RachaTokens.space5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: RachaTokens.space4),
                    Center(
                      child: Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.primaryContainer,
                        ),
                        child: Icon(
                          Icons.vpn_key_outlined,
                          size: 32,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: RachaTokens.space4),
                    Text(
                      l10n.coupleJoinInstruction,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: RachaTokens.space5),
                    Container(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: RachaTokens.brL,
                        border: Border.all(
                          color: _complete
                              ? scheme.primary
                              : scheme.outlineVariant,
                          width: _complete ? 1.5 : RachaTokens.borderHairline,
                        ),
                      ),
                      child: TextField(
                        controller: _code,
                        autofocus: true,
                        textCapitalization: TextCapitalization.characters,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        style: TextStyle(
                          fontSize: RachaType.title,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 12,
                          color: scheme.primary,
                        ),
                        inputFormatters: [
                          _UpperCaseFormatter(),
                          FilteringTextInputFormatter.allow(RegExp('[A-Z0-9]')),
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: RachaTokens.space5,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _submit(),
                      ),
                    ),
                    const SizedBox(height: RachaTokens.space2),
                    Text(
                      l10n.coupleJoinHelp,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: RachaType.caption,
                      ),
                    ),
                    if (state.hasError) ...[
                      const SizedBox(height: RachaTokens.space3),
                      ErrorBanner(text: coupleErrorText(l10n, state.error!)),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(RachaTokens.space4),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: scheme.outlineVariant,
                    width: RachaTokens.borderHairline,
                  ),
                ),
              ),
              child: FilledButton(
                onPressed: (loading || !_complete) ? null : _submit,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.coupleJoinSubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
