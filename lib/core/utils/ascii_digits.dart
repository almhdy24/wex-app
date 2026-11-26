/// Convert Eastern-Arabic / Persian numerals to ASCII (web util parity).
String toAsciiDigits(String input) {
  const eastern = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  final b = StringBuffer();
  for (final ch in input.split('')) {
    final e = eastern.indexOf(ch);
    final p = persian.indexOf(ch);
    if (e != -1) {
      b.write(e);
    } else if (p != -1) {
      b.write(p);
    } else {
      b.write(ch);
    }
  }
  return b.toString();
}
