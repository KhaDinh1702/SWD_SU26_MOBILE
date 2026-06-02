import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/models/voucher_model.dart';
import 'package:wave/core/providers/customer_provider.dart';

// Provider cho từng status: unused, used, expired
final vouchersProvider = FutureProvider.family<List<VoucherModel>, String>((ref, status) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getMyVouchers(status: status);
});
