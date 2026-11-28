/// Standard API envelope: { success, message, data, errors, meta }.
class ApiEnvelope {
  final bool success;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic>? meta;

  ApiEnvelope({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.meta,
  });

  factory ApiEnvelope.fromJson(Map<String, dynamic> json) => ApiEnvelope(
        success: json['success'] == true,
        message: (json['message'] ?? '').toString(),
        data: json['data'],
        errors: (json['errors'] is Map)
            ? Map<String, dynamic>.from(json['errors'])
            : null,
        meta: (json['meta'] is Map)
            ? Map<String, dynamic>.from(json['meta'])
            : null,
      );
}

/// Pagination meta: { page, per_page, total, total_pages }.
class PageMeta {
  final int page, perPage, total, totalPages;
  const PageMeta(
      {required this.page,
      required this.perPage,
      required this.total,
      required this.totalPages});

  factory PageMeta.fromJson(Map<String, dynamic>? m) => PageMeta(
        page: (m?['page'] ?? 1) as int,
        perPage: (m?['per_page'] ?? 20) as int,
        total: (m?['total'] ?? 0) as int,
        totalPages: (m?['total_pages'] ?? 1) as int,
      );

  bool get hasMore => page < totalPages;
}
