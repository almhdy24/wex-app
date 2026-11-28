import 'package:flutter_test/flutter_test.dart';
import 'package:wex_app/core/utils/arabic_duration.dart';
import 'package:wex_app/core/utils/formatters.dart';
import 'package:wex_app/core/utils/ascii_digits.dart';
import 'package:wex_app/core/utils/sudan_phone.dart';
import 'package:wex_app/core/utils/server_time.dart';
import 'package:wex_app/core/utils/product_name.dart';
import 'package:wex_app/core/strings.dart';

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
      expect(formatSdg(1850000), '\u20661,850,000\u2069 ج.س');
      expect(formatSdg(null), '\u20660\u2069 ج.س');
      expect(formatSdg(94500, negative: true), '\u2066−94,500\u2069 ج.س');
      expect(formatPercent(3), '\u20663%\u2069');
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

  group('normalizeProductName', () {
    test('fixes the BROPOOK typo and title-cases', () {
      final t = normalizeProductName('HP BROPOOK 440 G7');
      expect(t.brand, 'HP');
      expect(t.model, 'ProBook 440 G7');
      expect(t.full, 'HP ProBook 440 G7');
    });
    test('keeps Intel core ids lowercase and Arabic names untouched', () {
      expect(normalizeProductName('LENOVO THINKPAD T480').full, 'Lenovo ThinkPad T480');
      expect(normalizeProductName('Dell Latitude 7490').full, 'Dell Latitude 7490');
      final ar = normalizeProductName('شنطة ظهر لابتوب');
      expect(ar.brand, '');
      expect(ar.model, 'شنطة ظهر لابتوب');
    });
  });

  group('Arabic result plurals', () {
    test('forms', () {
      expect(Ar.results(0), 'لا توجد نتائج');
      expect(Ar.results(1), 'نتيجة واحدة');
      expect(Ar.results(2), 'نتيجتان');
      expect(Ar.results(3), '3 نتائج');
      expect(Ar.results(10), '10 نتائج');
      expect(Ar.results(11), '11 نتيجة');
      expect(Ar.results(14), '14 نتيجة');
    });
  });
}
