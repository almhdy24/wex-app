/// Arabic count phrases. 0 / 1 / 2 / 3–10 / 11+ forms.
String _forms(int n, String zero, String one, String two, String few, String many) {
  if (n <= 0) return zero;
  if (n == 1) return one;
  if (n == 2) return two;
  if (n <= 10) return few.replaceAll('{n}', '$n');
  return many.replaceAll('{n}', '$n');
}

/// "لا أجهزة" / "جهاز واحد" / "جهازان" / "3 أجهزة" / "11 جهازًا"
String devicesLabel(int n) => _forms(n, 'لا أجهزة', 'جهاز واحد', 'جهازان', '{n} أجهزة', '{n} جهازًا');

/// "لا نتائج" / "نتيجة واحدة" / "نتيجتان" / "3 نتائج" / "11 نتيجة"
String resultsLabel(int n) => _forms(n, 'لا نتائج', 'نتيجة واحدة', 'نتيجتان', '{n} نتائج', '{n} نتيجة');

/// "قطعة واحدة" / "قطعتان" / "3 قطع" / "11 قطعة"
String piecesLabel(int n) => _forms(n, 'لا قطع', 'قطعة واحدة', 'قطعتان', '{n} قطع', '{n} قطعة');

/// "+2 أجهزة أخرى" style for order cards: n is the number of OTHER devices.
String otherDevicesLabel(int n) =>
    _forms(n, '', 'جهاز آخر', 'جهازان آخران', '{n} أجهزة أخرى', '{n} جهازًا آخر');
