import 'package:intl/intl.dart';

/// Money formatting for costs. Costs are per date and per currency — a couple
/// travelling records one dinner in MXN and another in USD, and totals are shown
/// broken down by currency, never added together.
///
/// [amount] accepts a `num` (per-date `cost` from the API) or a decimal `String`
/// (the exact per-currency subtotals the summary endpoints return).
String formatMoney(Object? amount, String currency, {String? locale}) {
  final value = switch (amount) {
    num n => n,
    String s => num.tryParse(s) ?? 0,
    _ => 0,
  };
  return NumberFormat.currency(
    locale: locale,
    name: currency,
    // Let intl pick the symbol for well-known codes; fall back to the code.
    symbol: _symbols[currency] ?? '$currency ',
  ).format(value);
}

/// Renders a `{currency: "amount"}` map as one line, each currency formatted and
/// joined with a middle dot. Returns [ifEmpty] when there is nothing to show.
String formatMoneyByCurrency(
  Map<String, String> byCurrency, {
  String? locale,
  String ifEmpty = '—',
}) {
  if (byCurrency.isEmpty) return ifEmpty;
  final keys = byCurrency.keys.toList()..sort();
  return keys
      .map((c) => formatMoney(byCurrency[c], c, locale: locale))
      .join('  ·  ');
}

const _symbols = <String, String>{
  'MXN': r'$',
  'USD': r'US$',
  'EUR': '€',
  'GBP': '£',
  'CAD': r'C$',
  'JPY': '¥',
  'BRL': r'R$',
  'ARS': r'AR$',
  'COP': r'COL$',
  'CLP': r'CLP$',
  'PEN': 'S/',
};

/// The currency codes offered in the date form's picker.
const kCommonCurrencies = <String>[
  'MXN',
  'USD',
  'EUR',
  'GBP',
  'CAD',
  'JPY',
  'BRL',
  'ARS',
  'COP',
  'CLP',
  'PEN',
];
