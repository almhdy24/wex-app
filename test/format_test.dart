import 'package:flutter_test/flutter_test.dart';
import 'package:wex_app/core/format/dates.dart';
import 'package:wex_app/core/format/money.dart';
import 'package:wex_app/core/format/plural.dart';
import 'package:wex_app/core/format/promo_schedule.dart';
import 'package:wex_app/core/format/store_status.dart';

void main() {
  group('formatMoney', () {
    test('positive uses isolates around the number and keeps the unit outside', () {
      expect(formatMoney(1474400).codeUnits,
          [0x2066, ...'1,474,400'.codeUnits, 0x2069, 0x20, ...'ج.س'.codeUnits]);
    });
    test('negative puts the minus (U+2212) INSIDE the isolate', () {
      final s = formatMoney(-157500);
      expect(s.codeUnitAt(0), 0x2066);
      expect(s.codeUnitAt(1), 0x2212);
      expect(stripIsolates(s), '−157,500 ج.س');
      expect(s.indexOf(String.fromCharCode(0x2069)), greaterThan(s.indexOf('157,500')));
    });
    test('small and zero amounts', () {
      expect(stripIsolates(formatMoney(0)), '0 ج.س');
      expect(stripIsolates(formatMoney(999)), '999 ج.س');
      expect(stripIsolates(formatMoney(1000)), '1,000 ج.س');
    });
    test('order number is isolated and has no line breaks', () {
      final s = formatOrderNo(' WEX-20261128-0042 ');
      expect(stripIsolates(s), 'WEX-20261128-0042');
      expect(s.contains('\n'), isFalse);
    });
  });

  group('dates (Africa/Khartoum UTC+2)', () {
    test('format with Arabic month and ص/م', () {
      // 2026-11-26 23:48 UTC == 27 Nov 01:48 Khartoum
      expect(formatDateTimeAr(DateTime.utc(2026, 11, 26, 23, 48)), '27 نوفمبر 2026 · 1:48 ص');
      expect(formatDateTimeAr(DateTime.utc(2026, 11, 27, 10, 5)), '27 نوفمبر 2026 · 12:05 م');
      expect(formatTime12(DateTime.utc(2026, 1, 1, 22, 0)), '12:00 ص');
    });
    test('countdown formatting', () {
      expect(formatCountdown(const Duration(minutes: 5, seconds: 9)), '05:09');
      expect(formatCountdown(const Duration(hours: 2, minutes: 14, seconds: 9)), '02:14:09');
      expect(formatCountdown(const Duration(seconds: 59), alwaysHours: true), '00:00:59');
      expect(formatCountdown(const Duration(seconds: -5)), '00:00');
    });
  });

  group('Arabic plurals', () {
    test('results', () {
      expect([0, 1, 2, 3, 10, 11, 100].map(resultsLabel).toList(),
          ['لا نتائج', 'نتيجة واحدة', 'نتيجتان', '3 نتائج', '10 نتائج', '11 نتيجة', '100 نتيجة']);
    });
    test('devices', () {
      expect([0, 1, 2, 3, 10, 11, 100].map(devicesLabel).toList(),
          ['لا أجهزة', 'جهاز واحد', 'جهازان', '3 أجهزة', '10 أجهزة', '11 جهازًا', '100 جهازًا']);
    });
  });

  group('storeStatus', () {
    // Sun..Sat 9:00-21:00 except Friday closed; Saturday closes after midnight (09:00-01:00).
    final hours = <int, DayHours?>{
      for (final d in [7, 1, 2, 3, 4]) d: const DayHours(9 * 60, 21 * 60),
      5: null,
      6: const DayHours(9 * 60, 60),
    };
    // 2026-11-23 is a Monday.
    DateTime k(int day, int h, int m) => DateTime.utc(2026, 11, day, h - 2, m);
    test('open during the day', () {
      final s = storeStatus(k(23, 12, 0), hours);
      expect(s.isOpen, isTrue);
      expect(s.text, 'مفتوح الآن · يُغلق 9:00 م');
    });
    test('closed before opening says opens today', () {
      final s = storeStatus(k(23, 7, 30), hours);
      expect(s.isOpen, isFalse);
      expect(s.text, 'مغلق الآن · يفتح 9:00 ص');
    });
    test('after closing says opens tomorrow', () {
      final s = storeStatus(k(23, 22, 0), hours);
      expect(s.text, 'مغلق الآن · يفتح غدًا 9:00 ص');
    });
    test('friday closed all day -> opens saturday', () {
      final s = storeStatus(k(27, 12, 0), hours); // Friday
      expect(s.isOpen, isFalse);
      expect(s.text, 'مغلق الآن · يفتح غدًا 9:00 ص');
    });
    test('after midnight window stays open (saturday 09:00-01:00)', () {
      final sat = storeStatus(k(28, 23, 30), hours);
      expect(sat.isOpen, isTrue);
      final sunAfterMidnight = storeStatus(k(29, 0, 30), hours); // Sunday 00:30 -> still Saturday's window
      expect(sunAfterMidnight.isOpen, isTrue);
      expect(sunAfterMidnight.text, 'مفتوح الآن · يُغلق 1:00 ص');
      final sunClosed = storeStatus(k(29, 1, 30), hours);
      expect(sunClosed.isOpen, isFalse);
    });
  });

  group('promo schedule', () {
    final now = DateTime.utc(2026, 11, 28, 12);
    test('inactive never shows', () {
      expect(isPromoActive(nowUtc: now, isActive: false), isFalse);
    });
    test('open-ended nulls', () {
      expect(isPromoActive(nowUtc: now, isActive: true), isTrue);
    });
    test('before start / after end', () {
      expect(isPromoActive(nowUtc: now, isActive: true, startsAtUtc: now.add(const Duration(hours: 1))), isFalse);
      expect(isPromoActive(nowUtc: now, isActive: true, endsAtUtc: now), isFalse);
      expect(isPromoActive(nowUtc: now, isActive: true, startsAtUtc: now, endsAtUtc: now.add(const Duration(seconds: 1))), isTrue);
    });
  });
}
