import 'package:intl/intl.dart';

const sdgUnit = 'ج.س';

/// Unicode isolates: keep numbers/signs/percents visually intact inside RTL text.
/// LRI (U+2066) … PDI (U+2069).
const _lri = '\u2066';
const _pdi = '\u2069';

/// Wraps [s] in an LTR isolate so digits, minus and % never reorder in RTL context.
String isolate(String s) => '$_lri$s$_pdi';

final _sdg = NumberFormat('#,##0', 'en_US');

/// "1,850,000" (Western digits, no unit). Callers isolate/align direction.
String formatSdgAmount(num? value) => _sdg.format((value ?? 0).round());

/// Bidi-safe money string: "‎1,850,000‎ ج.س", negative as "−94,500 ج.س".
String formatSdg(num? value, {bool negative = false}) =>
    '${isolate('${negative ? '−' : ''}${formatSdgAmount(value)}')} $sdgUnit';

/// Bidi-safe percent: "3%" (ASCII digits + percent sign, one LTR run).
String formatPercent(num value) => isolate('${value.round()}%');

/// Africa/Khartoum is UTC+2 (no DST). Render 12-hour with ص/م, Western digits.
String format12hTime(DateTime utc) {
  final k = utc.toUtc().add(const Duration(hours: 2));
  final h12 = k.hour % 12 == 0 ? 12 : k.hour % 12;
  final mm = k.minute.toString().padLeft(2, '0');
  final suffix = k.hour < 12 ? 'ص' : 'م';
  return '$h12:$mm $suffix';
}

const _monthsAr = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

/// "12 نوفمبر 2026 · 3:05 م" in Africa/Khartoum, Western digits, one format app-wide.
String formatDateTimeAr(DateTime utc) {
  final k = utc.toUtc().add(const Duration(hours: 2));
  return '${isolate('${k.day} ${_monthsAr[k.month - 1]} ${k.year}')} · ${format12hTime(utc)}';
}

/// "3 س 20 د" / "45 د" remaining time, bidi-safe.
String formatRemaining(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h > 0) return isolate('$h س $m د');
  return isolate('${m < 1 ? 1 : m} د');
}
