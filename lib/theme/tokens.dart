import 'package:flutter/material.dart';

/// Design tokens for Racha. No widget writes a raw colour, radius or spacing
/// value — everything comes from here. The scale is deliberately short: seven
/// spaces, four radii, three shadows, seven text sizes. If an eighth value seems
/// necessary the layout is usually the thing to fix.
class RachaTokens {
  const RachaTokens._();

  /// The single brand seed. [ColorScheme.fromSeed] derives everything else for
  /// light and dark.
  static const Color seed = Color(0xFF8E2C4E);

  /// The one colour that is allowed to shout: the streak counter. Everything
  /// else stays neutral.
  static const Color streakLoud = seed;

  /// The only sanctioned exception to "one loud colour": a week at risk.
  static const Color atRiskLight = Color(0xFFB26A00);
  static const Color atRiskDark = Color(0xFFF2B45C);

  /// State accent for a covered week (brief: "verde = semana cubierta"). Used
  /// only for the small status pill, never as a surface.
  static const Color okLight = Color(0xFF2E7D32);
  static const Color okDark = Color(0xFF7CC47F);

  /// The streak hero is the one surface allowed a fill instead of tone + border.
  /// Fixed plum in both themes — it always carries white text, so it needs no
  /// light/dark variant.
  static const List<Color> streakGradient = [Color(0xFF3B0020), Color(0xFF8E2C4E)];

  // --- Spacing (7) ---
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;
  static const double space7 = 48;

  // --- Radius (4) ---
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 20;
  static const double radiusFull = 999;

  static const BorderRadius brS = BorderRadius.all(Radius.circular(radiusS));
  static const BorderRadius brM = BorderRadius.all(Radius.circular(radiusM));
  static const BorderRadius brL = BorderRadius.all(Radius.circular(radiusL));

  /// Hairline that separates a card from its background. Hierarchy is by tone
  /// and this 1px border, never by shadow.
  static const double borderHairline = 1;

  // --- Shadows (3). Only the FAB and things that truly float use these. ---
  static const List<BoxShadow> shadowNone = <BoxShadow>[];
  static const List<BoxShadow> shadowRaised = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> shadowOverlay = [
    BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 8)),
  ];
}

/// The seven-step type scale, applied on top of the system font.
class RachaType {
  const RachaType._();

  static const double display = 56; // the streak counter, and only that
  static const double title = 28;
  static const double headline = 22;
  static const double body = 16;
  static const double callout = 14;
  static const double caption = 13;
  static const double micro = 11;
}
