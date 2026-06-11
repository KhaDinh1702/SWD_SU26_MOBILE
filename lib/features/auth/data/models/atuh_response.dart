import 'package:wave/features/auth/data/models/user_model.dart';

class AuthResponse {
  final String token;
  final String refreshToken;
  final UserModel user;

  const AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final userJson = root['user'] ?? root['account'] ?? root['profile'];
    return AuthResponse(
      token: (root['accessToken'] ?? root['token'] ?? '').toString(),
      refreshToken: (root['refreshToken'] ?? '').toString(),
      user: userJson is Map<String, dynamic>
          ? UserModel.fromJson(userJson)
          : const UserModel(id: '', email: '', name: ''),
    );
  }
}
