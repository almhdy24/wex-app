class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? avatarUrl;
  final bool googleLinked;
  final bool emailNotifications;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    this.googleLinked = false,
    this.emailNotifications = true,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: (j['id'] ?? 0) as int,
        name: (j['name'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        phone: j['phone']?.toString(),
        role: (j['role'] ?? 'customer').toString(),
        avatarUrl: j['avatar_url']?.toString(),
        googleLinked: j['google_linked'] == true,
        emailNotifications: j['email_notifications'] != false,
      );
}
