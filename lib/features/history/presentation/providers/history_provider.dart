import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/models/order_model.dart';
import 'package:wave/core/providers/customer_provider.dart';

final myOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getMyOrders();
});
