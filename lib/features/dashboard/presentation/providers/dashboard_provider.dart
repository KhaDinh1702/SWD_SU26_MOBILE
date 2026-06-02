import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/models/loyalty_model.dart';
import 'package:wave/core/models/service_model.dart';
import 'package:wave/core/providers/customer_provider.dart';

final loyaltyProvider = FutureProvider.autoDispose<LoyaltyModel>((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getLoyalty();
});

final servicesProvider = FutureProvider.autoDispose<List<ServiceTypeModel>>((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getServiceTypes();
});
