import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Refresh token lives in secure storage; access token stays in memory only.
class TokenStore {
  static const _kRefresh = 'wex_refresh_token';
  final FlutterSecureStorage _storage;

  TokenStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> readRefresh() => _storage.read(key: _kRefresh);
  Future<void> writeRefresh(String token) =>
      _storage.write(key: _kRefresh, value: token);
  Future<void> clear() => _storage.delete(key: _kRefresh);
}
