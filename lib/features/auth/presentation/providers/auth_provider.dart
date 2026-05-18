import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:flutter_app/core/storage/token_storage.dart';
import 'package:flutter_app/features/auth/data/repositories/auth_api.dart';
import 'package:flutter_app/features/auth/data/repositories/auth_repository.dart';

final tokenStorageProvider = Provider((_) => TokenStorage());

final dioProvider = Provider((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return DioClient.create(tokenStorage);
});

final authApiProvider = Provider((ref) => AuthApi(ref.watch(dioProvider)));

final authRepositoryProvider =
    Provider((ref) => AuthRepository(ref.watch(authApiProvider)));
