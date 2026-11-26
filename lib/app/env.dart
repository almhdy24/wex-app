/// Compile-time config via --dart-define (defaults to production).
abstract final class Env {
  static const origin = String.fromEnvironment(
    'WEX_ORIGIN',
    defaultValue: 'https://wex-technology.com',
  );
  static String get apiBase => '$origin/api/v1';

  /// Product/proof image paths from the API are relative → prefix with this.
  static String assetUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return '$origin/$clean';
  }
}
