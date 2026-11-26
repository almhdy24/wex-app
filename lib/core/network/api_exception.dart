/// Raised when the API envelope reports success:false, or on transport errors.
class ApiException implements Exception {
  final String message;
  final Map<String, String> errors; // field -> Arabic message
  final int? statusCode;

  ApiException(this.message, {this.errors = const {}, this.statusCode});

  String? fieldError(String field) => errors[field];

  @override
  String toString() => 'ApiException($statusCode): $message';
}
