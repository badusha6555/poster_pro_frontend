import 'package:dio/dio.dart';

import '../../models/api_error.dart';
import '../config/api_config.dart';
import '../storage/secure_storage_service.dart';

/// Builds the single shared Dio instance used for all API calls.
///
/// - Attaches `Authorization: Bearer <token>` to every request when a token
///   is present in secure storage.
/// - On a 401 response, clears the stored session and invokes
///   [onUnauthorized] so the app can redirect to the login screen.
Dio createDioClient({
  required SecureStorageService storage,
  required void Function() onUnauthorized,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}',
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await storage.clearSession();
          onUnauthorized();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
}

/// Maps a [DioException] to a friendly [ApiError], parsing the backend's
/// `{"message": ...}` / `{"message": ..., "errors": {...}}` error shape
/// when present.
ApiError mapDioError(DioException error) {
  final data = error.response?.data;
  if (data is Map<String, dynamic> && data.containsKey('message')) {
    return ApiError.fromJson(data);
  }
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return ApiError.generic('Connection timed out. Check your network and try again.');
    case DioExceptionType.connectionError:
      return ApiError.generic('Could not reach the server. Check your connection.');
    default:
      return ApiError.generic('Something went wrong. Please try again.');
  }
}
