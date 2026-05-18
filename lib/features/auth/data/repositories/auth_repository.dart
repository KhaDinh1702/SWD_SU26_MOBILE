import 'package:wave/features/auth/data/models/atuh_response.dart';
import 'package:wave/features/auth/data/models/login_request.dart';
import 'package:wave/features/auth/data/models/register_request.dart';
import 'package:wave/features/auth/data/repositories/auth_api.dart';

class AuthRepository {
  final AuthApi _api;

  AuthRepository(this._api);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _api.login(LoginRequest(email: email, password: password));
  }

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String dateOfBirth,
  }) {
    return _api.register(RegisterRequest(
      name: name,
      phone: phone,
      email: email,
      password: password,
      dateOfBirth: dateOfBirth,
    ));
  }

  Future<AuthResponse> refresh(String refreshToken) {
    return _api.refresh(refreshToken);
  }
}
