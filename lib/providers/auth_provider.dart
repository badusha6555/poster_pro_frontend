import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  const AuthState({required this.status, this.email, this.shopName});

  final AuthStatus status;
  final String? email;
  final String? shopName;

  const AuthState.loading() : this(status: AuthStatus.loading);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);
  const AuthState.authenticated({required String email, required String shopName})
      : this(status: AuthStatus.authenticated, email: email, shopName: shopName);
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState.loading()) {
    _ref.listen<int>(unauthorizedSignalProvider, (previous, next) {
      if (previous != null && next != previous) {
        logout();
      }
    });
    _restoreSession();
  }

  final Ref _ref;

  Future<void> _restoreSession() async {
    final storage = _ref.read(secureStorageProvider);
    final token = await storage.readToken();
    final email = await storage.readEmail();
    final shopName = await storage.readShopName();
    if (token != null && email != null && shopName != null) {
      state = AuthState.authenticated(email: email, shopName: shopName);
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    final response = await _ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    await _persistSession(response.token, response.email, response.shopName);
  }

  Future<void> register({
    required String email,
    required String password,
    required String shopName,
  }) async {
    final response = await _ref
        .read(authRepositoryProvider)
        .register(email: email, password: password, shopName: shopName);
    await _persistSession(response.token, response.email, response.shopName);
  }

  Future<void> _persistSession(String token, String email, String shopName) async {
    await _ref.read(secureStorageProvider).saveSession(
          token: token,
          email: email,
          shopName: shopName,
        );
    state = AuthState.authenticated(email: email, shopName: shopName);
  }

  Future<void> logout() async {
    await _ref.read(secureStorageProvider).clearSession();
    state = const AuthState.unauthenticated();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
