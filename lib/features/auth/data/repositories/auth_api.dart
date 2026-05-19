import 'package:dio/dio.dart';
import 'package:wave/core/network/api_enpoints.dart';
import 'package:wave/features/auth/data/models/atuh_response.dart';
import 'package:wave/features/auth/data/models/login_request.dart';
import 'package:wave/features/auth/data/models/register_request.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> register(RegisterRequest request) async {
    await _dio.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );
  }

  Future<AuthResponse> refresh(String refreshToken) async {
    final response = await _dio.post(
      ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken},
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
