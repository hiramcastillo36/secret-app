import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../application/couple.dart';

/// Shows the invite code large and shareable, polls GET /couples/me softly and
/// moves on to home by itself when the partner joins. Leaving and coming back
/// keeps the code.
class CoupleWaitingScreen extends ConsumerStatefulWidget {
  const CoupleWaitingScreen({super.key});

  @override
  ConsumerState<CoupleWaitingScreen> createState() =>
      _CoupleWaitingScreenState();
}

class _CoupleWaitingScreenState extends ConsumerState<CoupleWaitingScreen>
    with WidgetsBindingObserver {
  Timer? _poll;
  int _polls = 0;
  bool _stalled = false;
  bool _rotating = false;

  // ~15 minutes at the capped 30s interval, then it stops and offers a manual
  // check (audit F, medium: it polled every 4s forever, no backoff, no cap and
  // kept going in the background).
  static const _maxPolls = 40;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _poll?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _polls = 0;
      _stalled = false;
      ref.invalidate(coupleMeProvider);
      _schedule();
    } else {
      _poll?.cancel();
      _poll = null;
    }
  }

  Duration _interval() {
    if (_polls < 2) return const Duration(seconds: 4);
    if (_polls < 4) return const Duration(seconds: 8);
    if (_polls < 8) return const Duration(seconds: 15);
    return const Duration(seconds: 30);
  }

  void _schedule() {
    _poll?.cancel();
    if (_polls >= _maxPolls) {
      if (mounted) setState(() => _stalled = true);
      return;
    }
    _poll = Timer(_interval(), () {
      _polls++;
      ref.invalidate(coupleMeProvider);
      _schedule();
    });
  }

  void _resumePolling() {
    setState(() {
      _polls = 0;
      _stalled = false;
    });
    ref.invalidate(coupleMeProvider);
    _schedule();
  }

  void _copy(String text, String toast) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(toast)));
  }

  Future<void> _rotateInvite() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _rotating = true);
    try {
      await ref.read(coupleControllerProvider.notifier).rotateInvite();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.coupleWaitingRotated)));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.localizedMessage(context))));
    } finally {
      if (mounted) setState(() => _rotating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final async = ref.watch(coupleMeProvider);

    ref.listen(coupleMeProvider, (_, next) {
      final view = next.valueOrNull;
      if (view != null && view.couple.isActive && mounted) {
        _poll?.cancel();
        _poll = null;
        context.go('/home');
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.coupleWaitingTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RachaTokens.space5),
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.commonNoConnection, textAlign: TextAlign.center),
                  const SizedBox(height: RachaTokens.space3),
                  TextButton(
                    onPressed: () => ref.invalidate(coupleMeProvider),
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            ),
            data: (view) {
              final code = view.couple.inviteCode ?? '——————';
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: RachaTokens.space6),
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 104,
                            width: 104,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scheme.primaryContainer,
                            ),
                            child: Icon(
                              Icons.favorite,
                              size: 48,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? RachaTokens.atRiskDark
                                            : RachaTokens.atRiskLight)
                                        .withValues(alpha: 0.2),
                                border: Border.all(
                                  color: scheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.hourglass_bottom,
                                size: 16,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? RachaTokens.atRiskDark
                                    : RachaTokens.atRiskLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: RachaTokens.space5),
                    Text(
                      l10n.coupleWaitingTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: RachaType.headline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: RachaTokens.space2),
                    Text(
                      l10n.coupleWaitingBody,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: RachaTokens.space6),
                    GestureDetector(
                      onTap: () => _copy(code, l10n.coupleWaitingCopied),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: RachaTokens.space5,
                          horizontal: RachaTokens.space4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: RachaTokens.brL,
                          border: Border.all(color: scheme.primary, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.coupleWaitingCodeLabel.toUpperCase(),
                              style: TextStyle(
                                color: scheme.onPrimaryContainer.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: RachaType.micro,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: RachaTokens.space2),
                            Text(
                              code,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: RachaType.title,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 10,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: RachaTokens.space1),
                            Text(
                              l10n.coupleWaitingTapToCopy,
                              style: TextStyle(
                                color: scheme.onPrimaryContainer.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: RachaType.micro,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: RachaTokens.space4),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _copy(code, l10n.coupleWaitingCopied),
                            icon: const Icon(Icons.copy, size: 18),
                            label: Text(l10n.profileCopy),
                          ),
                        ),
                        const SizedBox(width: RachaTokens.space2),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _copy(
                              l10n.coupleWaitingShareText(code),
                              l10n.coupleWaitingCopied,
                            ),
                            icon: const Icon(Icons.ios_share, size: 18),
                            label: Text(l10n.coupleWaitingShare),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: RachaTokens.space3),
                    Center(
                      child: TextButton.icon(
                        onPressed: _rotating ? null : _rotateInvite,
                        icon: _rotating
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.autorenew, size: 18),
                        label: Text(l10n.coupleWaitingRotate),
                      ),
                    ),
                    const SizedBox(height: RachaTokens.space6),
                    if (_stalled)
                      TextButton.icon(
                        onPressed: _resumePolling,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(l10n.commonRetry),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: RachaTokens.space2),
                          Text(
                            l10n.coupleWaitingPolling,
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: RachaType.caption,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: RachaTokens.space6),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
