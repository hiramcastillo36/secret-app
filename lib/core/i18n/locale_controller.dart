import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The user's language choice.
///
/// A `null` state means "Automatic": follow the device language, falling back to
/// Spanish. An explicit [Locale] pins the app to that language regardless of the
/// device, and is remembered across launches in [SharedPreferences] — it never
/// leaves the phone.
class LocaleController extends StateNotifier<Locale?> {
  LocaleController() : super(null) {
    _load();
  }

  static const _key = 'racha.locale';

  /// The languages the app ships translations for. Order is not significant.
  static const supported = ['es', 'en'];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && supported.contains(code)) {
      state = Locale(code);
    }
  }

  /// Persists [locale] (or clears the choice, reverting to Automatic, when null)
  /// and applies it immediately — no restart.
  Future<void> set(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale?>((ref) => LocaleController());

/// The concrete BCP-47 tag to send as `Accept-Language` and to format dates and
/// numbers with: the explicit choice if there is one, otherwise the device
/// language clamped to a supported one, otherwise Spanish.
String resolvedLanguageTag(Locale? choice) {
  if (choice != null) return choice.toLanguageTag();
  final device = PlatformDispatcher.instance.locale.languageCode;
  return LocaleController.supported.contains(device) ? device : 'es';
}
