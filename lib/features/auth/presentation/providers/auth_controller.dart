import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/storage/token_storage.dart';
import 'package:wave/features/auth/data/models/atuh_response.dart';
import 'package:wave/features/auth/presentation/providers/auth_provider.dart';

class AuthController extends AsyncNotifier<AuthResponse?> {
  @override
  Future<AuthResponse?> build() async => null;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await TokenStorage().saveTokens(
        accessToken: response.token,
        refreshToken: response.refreshToken,
      );
      return response;
    });
  }

  Future<void> logout() async {
    await TokenStorage().clear();
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthResponse?>(AuthController.new);
