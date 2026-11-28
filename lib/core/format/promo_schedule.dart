/// Pure schedule filter shared with the server rule (nulls are open-ended).
bool isPromoActive({
  required DateTime nowUtc,
  required bool isActive,
  DateTime? startsAtUtc,
  DateTime? endsAtUtc,
}) {
  if (!isActive) return false;
  if (startsAtUtc != null && nowUtc.isBefore(startsAtUtc)) return false;
  if (endsAtUtc != null && !nowUtc.isBefore(endsAtUtc)) return false;
  return true;
}
