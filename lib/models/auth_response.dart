/// Mirrors `com.posterpro.api.user.AuthResponse`, returned raw by both
/// POST /api/auth/login and POST /api/auth/register.
class AuthResponse {
  AuthResponse({
    required this.token,
    required this.email,
    required this.shopName,
  });

  final String token;
  final String email;
  final String shopName;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      email: json['email'] as String,
      shopName: json['shopName'] as String,
    );
  }
}
