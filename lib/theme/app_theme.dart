import 'package:flutter/material.dart';

import 'tokens.dart';

/// Builds the light and dark themes from the single brand seed. Dark mode is not
/// optional and not deferred: most contrast bugs only show up there.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: RachaTokens.seed,
      brightness: brightness,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // System typography — no bundled fonts. The user's accessibility text size
      // comes for free.
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: NoSplash.splashFactory,
    );

    return base.copyWith(
      // Cards separate from the background by tone + a 1px border, not shadow.
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: RachaTokens.brM,
          side: BorderSide(color: scheme.outlineVariant, width: RachaTokens.borderHairline),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: const OutlineInputBorder(
          borderRadius: RachaTokens.brS,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: RachaTokens.brS,
          borderSide: BorderSide(color: scheme.outlineVariant, width: RachaTokens.borderHairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: RachaTokens.brS,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RachaTokens.space4,
          vertical: RachaTokens.space3,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(borderRadius: RachaTokens.brS),
          textStyle: const TextStyle(fontSize: RachaType.body, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontSize: RachaType.callout, fontWeight: FontWeight.w500),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: RachaTokens.borderHairline,
        space: RachaTokens.space5,
      ),
    );
  }
}
