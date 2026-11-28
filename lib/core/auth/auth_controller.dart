import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../../data/models/auth_tokens.dart';
import '../../data/models/user.dart';
import 'auth_repository.dart';
import 'token_store.dart';

/// Root providers.
final serverTimeApiProvider = Provider<ApiClient>((ref) => ApiClient());
final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());
final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => AuthRepository(ref.read(serverTimeApiProvider)));

class AuthState {
  final User? user;
  final bool loading;
  final bool bootstrapped;
  const AuthState({this.user, this.loading = false, this.bootstrapped = false});

  bool get isAuthenticated => user != null;

  AuthState copyWith(
          {User? user,
          bool? loading,
          bool? bootstrapped,
          bool clearUser = false}) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        loading: loading ?? this.loading,
        bootstrapped: bootstrapped ?? this.bootstrapped,
      );
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
    (ref) => AuthController(ref));

class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthTokens? _tokens;

  AuthController(this._ref) : super(const AuthState()) {
    _bootstrap();
  }

  ApiClient get _api => _ref.read(serverTimeApiProvider);
  AuthRepository get _repo => _ref.read(authRepositoryProvider);
  TokenStore get _store => _ref.read(tokenStoreProvider);

  Future<void> _bootstrap() async {
    final rt = await _store.readRefresh();
    if (rt == null) {
      state = state.copyWith(bootstrapped: true);
      return;
    }
    try {
      final res = await _repo.refresh(rt);
      _apply(res.tokens, res.user);
    } catch (_) {
      await _store.clear();
    }
    state = state.copyWith(bootstrapped: true);
  }

  void _apply(AuthTokens tokens, User user) {
    _tokens = tokens;
    _api.dio.options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    if (tokens.refreshToken != null) _store.writeRefresh(tokens.refreshToken!);
    state = state.copyWith(user: user, loading: false);
  }

  Future<void> requestEmailOtp(String email) => _repo.requestEmailOtp(email);

  Future<void> verifyEmailOtp(
      {required String email, required String code, String? name}) async {
    state = state.copyWith(loading: true);
    try {
      final res =
          await _repo.verifyEmailOtp(email: email, code: code, name: name);
      _apply(res.tokens, res.user);
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> googleSignIn(String idToken) async {
    state = state.copyWith(loading: true);
    try {
      final res = await _repo.googleSignIn(idToken);
      _apply(res.tokens, res.user);
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  /// Native Google sign-in: obtains an ID token for the backend's web client.
  Future<bool> signInWithGoogle() async {
    final google = GoogleSignIn(
      serverClientId:
          '106015853692-ktr3bm0f597u8b7ad5dfimrps8ljna0t.apps.googleusercontent.com',
      scopes: const ['email', 'profile'],
    );
    try {
      final account = await google.signIn();
      if (account == null) return false; // cancelled
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) return false;
      await googleSignIn(idToken);
      return state.isAuthenticated;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _repo.logout(_tokens?.refreshToken);
    } catch (_) {}
    _tokens = null;
    _api.dio.options.headers.remove('Authorization');
    await _store.clear();
    state = state.copyWith(clearUser: true);
  }

  /// Ensures a fresh access token before an authed call (proactive refresh).
  Future<void> ensureFresh() async {
    final t = _tokens;
    if (t == null || !t.isNearExpiry) return;
    final rt = t.refreshToken ?? await _store.readRefresh();
    if (rt == null) return;
    try {
      final res = await _repo.refresh(rt);
      _apply(res.tokens, res.user);
    } on DioException catch (_) {}
  }
}
