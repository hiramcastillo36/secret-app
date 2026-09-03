import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:racha/l10n/app_localizations.dart';
import 'package:racha/features/plans/presentation/plan_form_screen.dart';

void main() {
  testWidgets('plan form requires a title before it will save', (tester) async {
    final router = GoRouter(
      initialLocation: '/plans/new',
      routes: [
        GoRoute(path: '/plans/new', builder: (_, __) => const PlanFormScreen()),
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

    // With no date the primary action is "Guardar idea" and the date toggle is off.
    expect(find.text('Guardar idea'), findsOneWidget);
    expect(find.text('¿Tienen fecha?'), findsOneWidget);

    // Tapping save with an empty title surfaces the name-required validation and
    // never leaves the screen (no network call).
    await tester.tap(find.text('Guardar idea'));
    await tester.pump();
    expect(find.text('Escribe tu nombre'), findsOneWidget);
  });
}
