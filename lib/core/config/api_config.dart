/// Backend base URL configuration.
///
/// Change [baseUrl] below depending on where the Spring Boot backend is
/// reachable from:
///   - Android emulator talking to a backend on your host machine:
///       http://10.0.2.2:8080
///   - iOS simulator / desktop / web talking to a backend on your host:
///       http://localhost:8080
///   - Physical device on the same LAN as the backend:
///       http://YOUR_MACHINE_LAN_IP:8080  (e.g. http://192.168.8.107:8080)
///
/// To switch environments per build without editing this file, run with:
///   flutter run --dart-define=API_BASE_URL=http://192.168.8.107:8080
class ApiConfig {
  ApiConfig._();

  static const String _defaultBaseUrl = 'http://10.99.143.29:8080';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  static const String apiPrefix = '/api';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
