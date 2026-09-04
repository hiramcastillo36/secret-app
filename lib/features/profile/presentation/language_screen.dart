import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth.dart';

/// /profile/language — Automatic, Español or English. The choice applies
/// instantly (no restart) and is stored on the device; it is also pushed to
/// the server (PATCH /me/locale) so reminder emails and push, which have no
/// request to read Accept-Language from, use it too.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final choice = ref.watch(localeControllerProvider);
    final controller = ref.read(localeControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    Widget option({
      required String title,
      String? subtitle,
      required Locale? value,
    }) {
      final selected = choice?.languageCode == value?.languageCode;
      return ListTile(
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: selected ? Icon(Icons.check, color: scheme.primary) : null,
        selected: selected,
        onTap: () {
          controller.set(value);
          ref
              .read(authActionsProvider.notifier)
              .syncLocale(resolvedLanguageTag(value));
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.languageTitle)),
      body: ListView(
        children: [
          option(
            title: l10n.languageAutomatic,
            subtitle: l10n.languageAutomaticHint,
            value: null,
          ),
          const Divider(height: 0),
          option(title: l10n.languageSpanish, value: const Locale('es')),
          option(title: l10n.languageEnglish, value: const Locale('en')),
        ],
      ),
    );
  }
}

/// Label for the active choice, used by the "Language" row in My account.
String languageLabel(AppLocalizations l10n, Locale? choice) =>
    switch (choice?.languageCode) {
      'es' => l10n.languageSpanish,
      'en' => l10n.languageEnglish,
      _ => l10n.languageAutomatic,
    };
