import 'package:dio/dio.dart';
import '../../app/env.dart';
import '../utils/server_time.dart';
import 'api_envelope.dart';
import 'api_exception.dart';

/// Thin wrapper over Dio that unwraps the Wex API envelope and tracks server time.
/// Auth (bearer + refresh) is attached via [attachAuth] interceptor from core/auth.
class ApiClient {
  final Dio dio;
  final ServerTime serverTime;

  ApiClient._(this.dio, this.serverTime);

  factory ApiClient({ServerTime? serverTime}) {
    final st = serverTime ?? ServerTime();
    final dio = Dio(BaseOptions(
      baseUrl: Env.apiBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Accept-Language': 'ar',
        // Native client: makes /auth/* return refresh_token in the JSON body.
        'X-Client': 'native',
      },
      // We handle non-2xx ourselves so the envelope error surfaces.
      validateStatus: (_) => true,
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onResponse: (resp, handler) {
        final dateHeader = resp.headers.value('date');
        if (dateHeader != null) {
          final parsed = _parseHttpDate(dateHeader);
          if (parsed != null) st.sync(parsed);
        }
        handler.next(resp);
      },
    ));
    return ApiClient._(dio, st);
  }

  Future<ApiEnvelope> request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Options? options,
  }) async {
    final resp = await dio.request(
      path,
      queryParameters: query,
      data: body,
      options: (options ?? Options()).copyWith(method: method),
    );
    final raw = resp.data;
    if (raw is! Map) {
      throw ApiException('استجابة غير متوقعة من الخادم', statusCode: resp.statusCode);
    }
    final env = ApiEnvelope.fromJson(Map<String, dynamic>.from(raw));
    if (!env.success) {
      throw ApiException(
        env.message.isEmpty ? 'حدث خطأ غير متوقع' : env.message,
        errors: env.errors?.map((k, v) => MapEntry(k, v.toString())) ?? const {},
        statusCode: resp.statusCode,
      );
    }
    return env;
  }

  Future<ApiEnvelope> get(String path, {Map<String, dynamic>? query}) =>
      request('GET', path, query: query);
  Future<ApiEnvelope> post(String path, {Object? body, Options? options}) =>
      request('POST', path, body: body, options: options);
  Future<ApiEnvelope> patch(String path, {Object? body}) =>
      request('PATCH', path, body: body);
  Future<ApiEnvelope> delete(String path, {Object? body}) =>
      request('DELETE', path, body: body);
}

DateTime? _parseHttpDate(String value) {
  try {
    return HttpDateParser.parse(value);
  } catch (_) {
    return null;
  }
}

/// Minimal RFC-1123 HTTP date parser (avoids extra deps).
abstract final class HttpDateParser {
  static const _months = {
    'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
    'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
  };

  static DateTime? parse(String s) {
    // e.g. "Wed, 26 Nov 2026 20:00:00 GMT"
    final m = RegExp(r'(\d{1,2}) (\w{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2})').firstMatch(s);
    if (m == null) return null;
    final month = _months[m.group(2)];
    if (month == null) return null;
    return DateTime.utc(
      int.parse(m.group(3)!), month, int.parse(m.group(1)!),
      int.parse(m.group(4)!), int.parse(m.group(5)!), int.parse(m.group(6)!),
    );
  }
}
