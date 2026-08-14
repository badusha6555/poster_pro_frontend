import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps [FlutterSecureStorage] for the small set of auth values we persist.
class SecureStorageService {
  SecureStorageService() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _emailKey = 'auth_email';
  static const _shopNameKey = 'auth_shop_name';

  Future<void> saveSession({
    required String token,
    required String email,
    required String shopName,
  }) async {
    await Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _emailKey, value: email),
      _storage.write(key: _shopNameKey, value: shopName),
    ]);
  }

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<String?> readEmail() => _storage.read(key: _emailKey);

  Future<String?> readShopName() => _storage.read(key: _shopNameKey);

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _emailKey),
      _storage.delete(key: _shopNameKey),
    ]);
  }
}
