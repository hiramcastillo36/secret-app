import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:racha/features/auth/presentation/onboarding_screen.dart';
import 'package:racha/l10n/app_localizations.dart';

void main() {
  testWidgets('onboarding shows the promise and the two actions', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(path: '/register', builder: (_, __) => const Scaffold()),
        GoRoute(path: '/login', builder: (_, __) => const Scaffold()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // First card: the promise plus a single "Next" and a "Skip".
    expect(find.text('Salgan juntos'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);
    expect(find.text('Saltar'), findsOneWidget);

    // Advance to the last card; now both account actions are offered.
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Mantengan la racha'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Ya tengo una cuenta'), findsOneWidget);
  });
}
