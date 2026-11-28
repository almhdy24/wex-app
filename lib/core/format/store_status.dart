import 'dates.dart';

/// Opening window in minutes since local midnight. `close <= open` means it closes after midnight.
class DayHours {
  final int open;
  final int close;
  const DayHours(this.open, this.close);
}

class StoreStatus {
  final bool isOpen;
  final String text; // "مفتوح الآن · يُغلق 9:00 م" / "مغلق الآن · يفتح 9:00 ص"
  const StoreStatus(this.isOpen, this.text);
}

const _dayNames = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];

/// [hours] maps DateTime.weekday (1=Mon … 7=Sun) to that day's window (null = closed all day).
/// [nowUtc] is converted to Africa/Khartoum (UTC+2).
StoreStatus storeStatus(DateTime nowUtc, Map<int, DayHours?> hours) {
  final k = toKhartoum(nowUtc);
  final nowMin = k.hour * 60 + k.minute;
  final wd = k.weekday;

  // Currently open? Today's window, or yesterday's window that crosses midnight.
  final today = hours[wd];
  if (today != null) {
    final crosses = today.close <= today.open;
    if (!crosses && nowMin >= today.open && nowMin < today.close) {
      return StoreStatus(true, 'مفتوح الآن · يُغلق ${formatMinutes12(today.close)}');
    }
    if (crosses && nowMin >= today.open) {
      return StoreStatus(true, 'مفتوح الآن · يُغلق ${formatMinutes12(today.close)}');
    }
  }
  final yesterday = hours[wd == 1 ? 7 : wd - 1];
  if (yesterday != null && yesterday.close <= yesterday.open && nowMin < yesterday.close) {
    return StoreStatus(true, 'مفتوح الآن · يُغلق ${formatMinutes12(yesterday.close)}');
  }

  // Closed: find the next opening within a week.
  for (var i = 0; i < 8; i++) {
    final d = ((wd - 1 + i) % 7) + 1;
    final h = hours[d];
    if (h == null) continue;
    if (i == 0 && nowMin >= h.open) continue; // today's window already started/passed
    final when = formatMinutes12(h.open);
    if (i == 0) return StoreStatus(false, 'مغلق الآن · يفتح $when');
    if (i == 1) return StoreStatus(false, 'مغلق الآن · يفتح غدًا $when');
    return StoreStatus(false, 'مغلق الآن · يفتح ${_dayNames[d - 1]} $when');
  }
  return const StoreStatus(false, 'مغلق الآن');
}
