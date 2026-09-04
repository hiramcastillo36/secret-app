import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:racha/features/common/error_retry.dart';
import 'package:racha/l10n/app_localizations.dart';

Widget _host(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('shows a retry button and fires the callback', (tester) async {
    var tries = 0;
    await tester.pumpWidget(_host(ErrorRetry(onRetry: () => tries++)));
    await tester.pumpAndSettle();

    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Algo salió mal. Inténtalo de nuevo.'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    expect(tries, 1);
  });

  testWidgets('a custom message overrides the default', (tester) async {
    await tester.pumpWidget(
      _host(ErrorRetry(onRetry: () {}, message: 'Sin conexión')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión'), findsOneWidget);
    expect(find.text('Algo salió mal. Inténtalo de nuevo.'), findsNothing);
  });
}
