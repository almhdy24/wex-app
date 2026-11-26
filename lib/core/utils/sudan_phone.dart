import 'ascii_digits.dart';

/// Sudan mobile: 09XXXXXXXX or 01XXXXXXXX (10 digits).
bool isValidSudanPhone(String raw) {
  final d = toAsciiDigits(raw).replaceAll(RegExp(r'\s|-'), '');
  return RegExp(r'^0(9|1)\d{8}$').hasMatch(d);
}

String normalizeSudanPhone(String raw) =>
    toAsciiDigits(raw).replaceAll(RegExp(r'\s|-'), '');
