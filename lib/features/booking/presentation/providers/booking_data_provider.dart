import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/models/order_model.dart';
import 'package:wave/core/providers/customer_provider.dart';

// A family provider to fetch available slots based on serviceId and date.
final availableSlotsProvider = FutureProvider.autoDispose.family<List<AvailableSlotModel>, ({String serviceId, String date})>((ref, args) async {
  final repo = ref.watch(customerRepositoryProvider);
  // date is YYYY-MM-DD. 
  // We need to pass from and to to cover the whole day.
  final from = '${args.date}T00:00:00.000Z';
  final to = '${args.date}T23:59:59.999Z';
  return repo.getAvailableSlots(args.serviceId, from, to);
});

// A family provider to preview order
final previewOrderProvider = FutureProvider.autoDispose.family<PreviewOrderResponseModel, ({String serviceId, String scheduledAt, String? voucherId})>((ref, args) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.previewOrder(args.serviceId, args.scheduledAt, args.voucherId);
});
