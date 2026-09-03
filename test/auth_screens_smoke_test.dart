import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:racha/l10n/app_localizations.dart';
import 'package:racha/features/auth/presentation/login_screen.dart';
import 'package:racha/features/auth/presentation/register_screen.dart';
import 'package:racha/features/couple/presentation/couple_setup_screen.dart';

Widget _host(String start, List<GoRoute> routes) => ProviderScope(
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        routerConfig: GoRouter(initialLocation: start, routes: routes),
      ),
    );

void main() {
  testWidgets('login renders the hero and the form actions', (tester) async {
    await tester.pumpWidget(_host('/login', [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/auth/forgot-password', builder: (_, __) => const Scaffold()),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Qué bueno verte'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsWidgets);
    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
  });

  testWidgets('register renders the hero and the password meter appears on input',
      (tester) async {
    await tester.pumpWidget(_host('/register', [
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/login', builder: (_, __) => const Scaffold()),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Crea tu cuenta'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).last, 'abc');
    await tester.pump();
    expect(find.text('Débil'), findsOneWidget);
  });

  testWidgets('couple setup offers the two paths', (tester) async {
    await tester.pumpWidget(_host('/couple/setup', [
      GoRoute(path: '/couple/setup', builder: (_, __) => const CoupleSetupScreen()),
      GoRoute(path: '/couple/create', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/couple/join', builder: (_, __) => const Scaffold()),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Crear nuestra pareja'), findsOneWidget);
    expect(find.text('Tengo un código'), findsOneWidget);
  });
}
