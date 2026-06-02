import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/models/loyalty_transaction_model.dart';
import 'package:wave/core/providers/customer_provider.dart';

final loyaltyTransactionsProvider = FutureProvider<LoyaltyTransactionListResponse>((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getLoyaltyTransactions(page: 1, limit: 100);
});
