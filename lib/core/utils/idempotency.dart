import 'dart:convert';
import 'dart:math';

/// Stable idempotency key for a checkout payload (web idempotencyKeyFor parity):
/// same payload → same key within an attempt, so retries don't double-create.
String idempotencyKeyFor(Object payload) {
  final json = jsonEncode(payload);
  var hash = 0x811c9dc5;
  for (final c in json.codeUnits) {
    hash ^= c;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  final rand = Random().nextInt(0x7FFFFFFF);
  return 'wex-${hash.toRadixString(16)}-${rand.toRadixString(16)}';
}
