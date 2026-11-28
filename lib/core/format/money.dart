/// Pure Dart (no flutter imports). Bidi-safe money, order numbers.
const String lri = '⁦'; // LEFT-TO-RIGHT ISOLATE
const String pdi = '⁩'; // POP DIRECTIONAL ISOLATE
const String currencyUnit = 'ج.س';

String isolate(String s) => '$lri$s$pdi';

String _commas(int abs) {
  final s = abs.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

/// "1,474,400" (sign-less, Western digits).
String formatAmount(int v) => _commas(v.abs());

/// "1,474,400 ج.س"; negative: "−157,500 ج.س". The sign is INSIDE the isolate so the
/// digits and the minus can never reorder in an RTL paragraph.
String formatMoney(int v) =>
    '${isolate('${v < 0 ? '−' : ''}${_commas(v.abs())}')} $currencyUnit';

/// Order number, forced LTR, never wraps (callers render it with softWrap:false).
String formatOrderNo(String no) => isolate(no.trim());
