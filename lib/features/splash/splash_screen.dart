import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/auth/session_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../auth/data/auth_repository.dart';
import '../auth/domain/models.dart';

/// Startup gate: reads the stored session, calls GET /me once and routes to
/// onboarding, pairing or home. Never a long spinner — it falls back to login
/// after two seconds.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    setState(() => _failed = false);
    try {
      await ref.read(sessionControllerProvider.notifier).bootstrap();
      final status = ref.read(sessionControllerProvider);
      if (status != AuthStatus.authenticated) {
        _goto('/onboarding');
        return;
      }

      final me = await ref
          .read(authRepositoryProvider)
          .me()
          .timeout(const Duration(seconds: 2));

      switch (me.route) {
        case BootstrapRoute.home:
          _goto('/home');
        case BootstrapRoute.coupleSetup:
          _goto('/couple/setup');
        case BootstrapRoute.onboarding:
          _goto('/onboarding');
      }
    } on ApiException catch (e) {
      if (e.status == 401) {
        await ref.read(sessionControllerProvider.notifier).signOut();
        _goto('/onboarding');
        return;
      }
      setState(() => _failed = true);
    } on TimeoutException {
      _goto('/login');
    } catch (_) {
      setState(() => _failed = true);
    }
  }

  void _goto(String location) {
    if (mounted) context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: RachaTokens.streakGradient,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(RachaTokens.space6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 88,
                  width: 88,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: RachaTokens.brL,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white, size: 44),
                ),
                const SizedBox(height: RachaTokens.space5),
                Text(l10n.appTitle,
                    style: const TextStyle(
                        fontSize: RachaType.title,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                const SizedBox(height: RachaTokens.space1),
                Text(l10n.splashTagline,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                const SizedBox(height: RachaTokens.space6),
                if (_failed)
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: RachaTokens.seed,
                    ),
                    onPressed: _boot,
                    child: Text(l10n.commonRetry),
                  )
                else
                  const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
