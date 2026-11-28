import 'money.dart';

const _months = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

/// Africa/Khartoum is fixed UTC+2 (no DST).
DateTime toKhartoum(DateTime utc) => utc.toUtc().add(const Duration(hours: 2));

/// "1:48 ص" (12-hour, Western digits).
String formatTime12(DateTime utc) {
  final k = toKhartoum(utc);
  final h = k.hour % 12 == 0 ? 12 : k.hour % 12;
  return '$h:${k.minute.toString().padLeft(2, '0')} ${k.hour < 12 ? 'ص' : 'م'}';
}

/// "27 نوفمبر 2026"
String formatDateAr(DateTime utc) {
  final k = toKhartoum(utc);
  return '${k.day} ${_months[k.month - 1]} ${k.year}';
}

/// "27 نوفمبر 2026 · 1:48 ص"
String formatDateTimeAr(DateTime utc) => '${formatDateAr(utc)} · ${formatTime12(utc)}';

/// Wall-clock minutes (0..1439) -> "9:00 م".
String formatMinutes12(int minutes) {
  final h = (minutes ~/ 60) % 24;
  final m = minutes % 60;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} ${h < 12 ? 'ص' : 'م'}';
}

/// Countdown: "mm:ss" under one hour, otherwise "hh:mm:ss". Never negative.
String formatCountdown(Duration d, {bool alwaysHours = false}) {
  final s = d.inSeconds < 0 ? 0 : d.inSeconds;
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = s % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return (h > 0 || alwaysHours) ? '${two(h)}:${two(m)}:${two(sec)}' : '${two(m)}:${two(sec)}';
}

/// Strips direction marks from [s] (handy for tests).
String stripIsolates(String s) => s.replaceAll(lri, '').replaceAll(pdi, '');
