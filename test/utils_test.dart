import 'package:flutter_test/flutter_test.dart';
import 'package:wex_app/core/utils/arabic_duration.dart';
import 'package:wex_app/core/utils/formatters.dart';
import 'package:wex_app/core/utils/ascii_digits.dart';
import 'package:wex_app/core/utils/sudan_phone.dart';
import 'package:wex_app/core/utils/server_time.dart';

void main() {
  group('formatHoursAr', () {
    test('grammatical forms', () {
      expect(formatHoursAr(1), 'ساعة واحدة');
      expect(formatHoursAr(2), 'ساعتين');
      expect(formatHoursAr(4), '4 ساعات');
      expect(formatHoursAr(11), '11 ساعة');
      expect(formatHoursAr(0), 'ساعة واحدة');
    });
  });

  group('formatSdg', () {
    test('thousands + unit', () {
      expect(formatSdg(1850000), '1,850,000 ج.س');
      expect(formatSdg(null), '0 ج.س');
    });
  });

  group('toAsciiDigits', () {
    test('eastern arabic to ascii', () {
      expect(toAsciiDigits('١٢٣٤٥٦'), '123456');
      expect(toAsciiDigits('09١٢'), '0912');
    });
  });

  group('sudan phone', () {
    test('valid/invalid', () {
      expect(isValidSudanPhone('0912345678'), true);
      expect(isValidSudanPhone('0112345678'), true);
      expect(isValidSudanPhone('12345'), false);
      expect(normalizeSudanPhone('091 234-5678'), '0912345678');
    });
  });

  group('ServerTime', () {
    test('seconds remaining uses server offset', () {
      final st = ServerTime();
      st.sync(DateTime.now().toUtc().add(const Duration(seconds: 60)));
      final target = DateTime.now().toUtc().add(const Duration(seconds: 120));
      final rem = st.secondsUntil(target);
      expect(rem, greaterThan(40));
      expect(rem, lessThanOrEqualTo(60));
    });
  });
}
