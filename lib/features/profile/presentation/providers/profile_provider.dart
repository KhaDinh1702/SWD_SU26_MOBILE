import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_app/features/profile/data/repositories/profile_api.dart';
import 'package:flutter_app/features/profile/data/repositories/profile_repository.dart';

final profileApiProvider =
    Provider((ref) => ProfileApi(ref.watch(dioProvider)));

final profileRepositoryProvider =
    Provider((ref) => ProfileRepository(ref.watch(profileApiProvider)));
