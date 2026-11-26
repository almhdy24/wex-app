/// Arabic grammatical hour count, used after a preposition (web util parity).
/// 1 → ساعة واحدة · 2 → ساعتين · 3–10 → N ساعات · 11+ → N ساعة
String formatHoursAr(num? value) {
  final n = (value == null || value < 1) ? 1 : value.round();
  if (n == 1) return 'ساعة واحدة';
  if (n == 2) return 'ساعتين';
  if (n <= 10) return '$n ساعات';
  return '$n ساعة';
}
