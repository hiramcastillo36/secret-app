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
/// onboarding, pairing or home. A slow or failing GET /me on a valid session
/// lands on /home anyway and lets Home's own loading and error states take over
/// (audit F-H4) — it never bounces a signed-in user to the login screen.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
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
          .timeout(const Duration(seconds: 6));

      switch (me.route) {
        case BootstrapRoute.home:
          _goto('/home');
        case BootstrapRoute.coupleSetup:
          _goto('/couple/setup');
      }
    } on ApiException catch (e) {
      if (e.status == 401) {
        await ref.read(sessionControllerProvider.notifier).signOut();
        _goto('/onboarding');
        return;
      }
      // Any other server error on a valid session: proceed to Home, which
      // renders its own error state (audit F-H4).
      _goto('/home');
    } on TimeoutException {
      // Slow network or a cold-start backend. The session is valid — go to
      // Home rather than making the user log in again.
      _goto('/home');
    } catch (_) {
      // Unknown failure: let the router's guard sort out where this lands.
      _goto('/home');
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
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: RachaTokens.space5),
                Text(
                  l10n.appTitle,
                  style: const TextStyle(
                    fontSize: RachaType.title,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: RachaTokens.space1),
                Text(
                  l10n.splashTagline,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: RachaTokens.space6),
                const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
