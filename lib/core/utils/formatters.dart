import 'package:intl/intl.dart';

const sdgUnit = 'ج.س';

final _sdg = NumberFormat('#,##0', 'en_US');

/// Price formatted with Western digits; caller isolates direction (LTR amount).
String formatSdgAmount(num? value) => _sdg.format((value ?? 0).round());

/// "1,850,000 ج.س"
String formatSdg(num? value) => '${formatSdgAmount(value)} $sdgUnit';

/// Africa/Khartoum is UTC+2 (no DST). Render 12-hour with ص/م, Western digits.
String format12hTime(DateTime utc) {
  final k = utc.toUtc().add(const Duration(hours: 2));
  final h12 = k.hour % 12 == 0 ? 12 : k.hour % 12;
  final mm = k.minute.toString().padLeft(2, '0');
  final suffix = k.hour < 12 ? 'ص' : 'م';
  return '$h12:$mm $suffix';
}
