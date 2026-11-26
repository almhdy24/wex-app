class AuthTokens {
  final String accessToken;
  final String? refreshToken;
  final int expiresIn; // seconds
  final DateTime obtainedAt;

  AuthTokens({
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
    DateTime? obtainedAt,
  }) : obtainedAt = obtainedAt ?? DateTime.now();

  DateTime get expiresAt => obtainedAt.add(Duration(seconds: expiresIn));
  bool get isNearExpiry =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 2)));

  factory AuthTokens.fromJson(Map<String, dynamic> j) => AuthTokens(
        accessToken: (j['access_token'] ?? '').toString(),
        refreshToken: j['refresh_token']?.toString(),
        expiresIn: (j['expires_in'] ?? 900) as int,
      );
}
