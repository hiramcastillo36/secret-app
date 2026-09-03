import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Relative day label ("hoy", "ayer", "hace 3 días") falling back to a localized
/// date. Uses the ambient locale so it reads right in es and en.
String relativeDay(BuildContext context, DateTime whenUtc) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final now = DateTime.now();
  final when = whenUtc.toLocal();
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(when.year, when.month, when.day)).inDays;

  final es = locale.startsWith('es');
  if (days == 0) return es ? 'Hoy' : 'Today';
  if (days == 1) return es ? 'Ayer' : 'Yesterday';
  if (days == -1) return es ? 'Mañana' : 'Tomorrow';
  if (days > 1 && days < 7) return es ? 'Hace $days días' : '$days days ago';
  if (days < -1 && days > -7) {
    final n = -days;
    return es ? 'En $n días' : 'In $n days';
  }
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
