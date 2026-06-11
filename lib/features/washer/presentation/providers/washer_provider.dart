import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/features/auth/presentation/providers/auth_provider.dart';
import 'package:wave/features/washer/data/models/washer_order_model.dart';
import 'package:wave/features/washer/data/repositories/washer_api.dart';
import 'package:wave/features/washer/data/repositories/washer_repository.dart';

final washerApiProvider = Provider<WasherApi>((ref) {
  return WasherApi(ref.watch(dioProvider));
});

final washerRepositoryProvider = Provider<WasherRepository>((ref) {
  return WasherRepository(ref.watch(washerApiProvider));
});

/// Danh sách tất cả work-order được giao cho washer.
final washerWorkOrdersProvider =
    FutureProvider.autoDispose<List<WasherOrderModel>>((ref) async {
  final repo = ref.watch(washerRepositoryProvider);
  return repo.getWorkOrders();
});
