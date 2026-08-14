/// Mirrors the raw error map shapes returned by
/// `com.posterpro.api.common.GlobalExceptionHandler`:
///   { "message": "..." }
///   { "message": "Validation failed", "errors": { field: message } }
class ApiError {
  ApiError({required this.message, this.fieldErrors});

  final String message;
  final Map<String, String>? fieldErrors;

  factory ApiError.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'];
    Map<String, String>? fieldErrors;
    if (rawErrors is Map) {
      fieldErrors = rawErrors.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    return ApiError(
      message: json['message']?.toString() ?? 'Something went wrong',
      fieldErrors: fieldErrors,
    );
  }

  factory ApiError.generic(String message) => ApiError(message: message);
}

class UnauthorizedException implements Exception {
  UnauthorizedException([this.message = 'Session expired, please log in again']);
  final String message;
}
