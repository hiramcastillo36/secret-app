import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';

/// Relative day label ("hoy", "ayer", "hace 3 días") falling back to a localized
/// date. Every string comes from the ARB catalogue, so a third language is not
/// silently English (audit F, medium: this branched on locale.startsWith('es')).
String relativeDay(BuildContext context, DateTime whenUtc) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  final now = DateTime.now();
  final when = whenUtc.toLocal();
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(when.year, when.month, when.day)).inDays;

  if (days == 0) return l10n.relativeToday;
  if (days == 1) return l10n.relativeYesterday;
  if (days == -1) return l10n.relativeTomorrow;
  if (days > 1 && days < 7) return l10n.relativeDaysAgo(days);
  if (days < -1 && days > -7) return l10n.relativeInDays(-days);
  return DateFormat.yMMMd(locale).format(when);
}

/// A neutral icon per place category.
IconData categoryIcon(String category) => switch (category) {
  'restaurant' => Icons.restaurant,
  'cafe' => Icons.local_cafe,
  'bar' => Icons.local_bar,
  'cinema' => Icons.movie,
  'park' => Icons.park,
  'museum' => Icons.museum,
  'hotel' => Icons.hotel,
  _ => Icons.place,
};
