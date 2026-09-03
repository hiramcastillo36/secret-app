import 'package:flutter_timezone/flutter_timezone.dart';

/// A broad set of IANA zones for the couple timezone picker. Not the full
/// database (that needs the `timezone` package), but enough that most users
/// find theirs; the device's own zone is added on top at runtime (audit F,
/// low: the picker hardcoded 15 zones, so someone in Europe/Berlin or
/// Asia/Tokyo could not create a couple).
const kCommonTimezones = <String>[
  // Americas
  'America/Mexico_City',
  'America/Tijuana',
  'America/Monterrey',
  'America/Cancun',
  'America/Bogota',
  'America/Lima',
  'America/Santiago',
  'America/Argentina/Buenos_Aires',
  'America/Sao_Paulo',
  'America/Caracas',
  'America/New_York',
  'America/Chicago',
  'America/Denver',
  'America/Phoenix',
  'America/Los_Angeles',
  'America/Anchorage',
  'America/Halifax',
  'America/Toronto',
  'Pacific/Honolulu',
  // Europe / Africa
  'Europe/London',
  'Europe/Madrid',
  'Europe/Lisbon',
  'Europe/Paris',
  'Europe/Berlin',
  'Europe/Rome',
  'Europe/Amsterdam',
  'Europe/Athens',
  'Europe/Istanbul',
  'Europe/Moscow',
  'Africa/Casablanca',
  'Africa/Lagos',
  'Africa/Johannesburg',
  'Africa/Cairo',
  'Africa/Nairobi',
  // Asia / Pacific
  'Asia/Jerusalem',
  'Asia/Dubai',
  'Asia/Karachi',
  'Asia/Kolkata',
  'Asia/Dhaka',
  'Asia/Bangkok',
  'Asia/Jakarta',
  'Asia/Singapore',
  'Asia/Shanghai',
  'Asia/Hong_Kong',
  'Asia/Tokyo',
  'Asia/Seoul',
  'Asia/Manila',
  'Australia/Perth',
  'Australia/Sydney',
  'Pacific/Auckland',
  'UTC',
];

/// The device's IANA zone, or `America/Mexico_City` if the platform can't
/// answer (matches the backend default).
Future<String> deviceTimezone() async {
  try {
    final id = (await FlutterTimezone.getLocalTimezone()).identifier;
    return id.isEmpty ? 'America/Mexico_City' : id;
  } catch (_) {
    return 'America/Mexico_City';
  }
}

/// [kCommonTimezones] with [preferred] guaranteed present and first.
List<String> timezoneOptions(String preferred) {
  final rest = kCommonTimezones.where((z) => z != preferred);
  return [preferred, ...rest];
}
