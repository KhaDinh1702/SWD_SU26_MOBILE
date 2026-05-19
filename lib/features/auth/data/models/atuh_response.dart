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

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: (json['accessToken'] ?? json['token'] ?? '') as String,
        refreshToken: (json['refreshToken'] ?? '') as String,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}
