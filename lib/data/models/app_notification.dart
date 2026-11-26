class AppNotification {
  final int id;
  final String type;
  final String title;
  final String body;
  final String? orderNumber;
  final String? url;
  final bool isRead;
  final DateTime? createdAt;
  const AppNotification({
    required this.id, required this.type, required this.title, required this.body,
    this.orderNumber, this.url, this.isRead = false, this.createdAt,
  });
  factory AppNotification.fromJson(Map<String, dynamic> j) {
    final data = (j['data'] is Map) ? Map<String, dynamic>.from(j['data']) : const {};
    return AppNotification(
      id: (j['id'] ?? 0) as int,
      type: (j['type'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      body: (j['body'] ?? '').toString(),
      orderNumber: (j['order_number'] ?? data['order_number'])?.toString(),
      url: data['url']?.toString(),
      isRead: j['is_read'] == true,
      createdAt: DateTime.tryParse((j['created_at'] ?? '').toString()),
    );
  }
}
