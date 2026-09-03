import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/i18n/locale_controller.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: RachaApp()));
}

class RachaApp extends ConsumerWidget {
  const RachaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // null = "Automatic": fall through to the device language below.
    final choice = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: choice,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // An explicit choice wins; otherwise match the device, then fall back to
      // Spanish. Keeping the callback means "Automatic" still tracks the device.
      localeResolutionCallback: (device, supported) {
        final want = choice ?? device;
        if (want != null) {
          for (final l in supported) {
            if (l.languageCode == want.languageCode) return l;
          }
        }
        return const Locale('es');
      },
      routerConfig: router,
    );
  }
}
