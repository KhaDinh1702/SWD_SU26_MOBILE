import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/network/api/customer_api.dart';
import 'package:wave/core/repositories/customer_repository.dart';
import 'package:wave/features/auth/presentation/providers/auth_provider.dart';

final customerApiProvider = Provider<CustomerApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CustomerApi(dio);
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final api = ref.watch(customerApiProvider);
  return CustomerRepository(api);
});
