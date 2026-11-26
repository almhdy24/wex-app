/// Tracks the offset between the server clock (HTTP Date header) and the device,
/// so the price-lock countdown is correct under clock skew (web parity).
class ServerTime {
  Duration _offset = Duration.zero;

  /// offset = serverNow - deviceNow
  void sync(DateTime serverUtc) {
    _offset = serverUtc.difference(DateTime.now().toUtc());
  }

  DateTime now() => DateTime.now().toUtc().add(_offset);

  /// Seconds remaining until [target], floored at zero.
  int secondsUntil(DateTime target) {
    final diff = target.toUtc().difference(now()).inSeconds;
    return diff < 0 ? 0 : diff;
  }
}
