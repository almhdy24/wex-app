import '../network/api_client.dart';
import '../../data/models/auth_tokens.dart';
import '../../data/models/user.dart';

/// Passwordless auth against /auth/*. Sends X-Client: native (set on ApiClient)
/// so the refresh token comes back in the JSON body.
class AuthRepository {
  final ApiClient api;
  AuthRepository(this.api);

  Future<void> requestEmailOtp(String email) async {
    await api.post('/auth/email/request', body: {'email': email});
  }

  Future<({AuthTokens tokens, User user})> verifyEmailOtp({
    required String email,
    required String code,
    String? name,
  }) async {
    final env = await api.post('/auth/email/verify', body: {
      'email': email,
      'code': code,
      if (name != null && name.isNotEmpty) 'name': name,
    });
    return _parse(env.data as Map<String, dynamic>);
  }

  Future<({AuthTokens tokens, User user})> googleSignIn(String idToken) async {
    final env = await api.post('/auth/google', body: {'id_token': idToken});
    return _parse(env.data as Map<String, dynamic>);
  }

  Future<({AuthTokens tokens, User user})> refresh(String refreshToken) async {
    final env =
        await api.post('/auth/refresh', body: {'refresh_token': refreshToken});
    return _parse(env.data as Map<String, dynamic>);
  }

  Future<void> logout(String? refreshToken) async {
    await api.post('/auth/logout',
        body: {if (refreshToken != null) 'refresh_token': refreshToken});
  }

  ({AuthTokens tokens, User user}) _parse(Map<String, dynamic> data) => (
        tokens: AuthTokens.fromJson(data),
        user: User.fromJson(Map<String, dynamic>.from(data['user'] as Map)),
      );
}
