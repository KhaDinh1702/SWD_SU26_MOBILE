import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:wave/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:wave/features/profile/presentation/providers/loyalty_management_provider.dart';

class LoyaltyPage extends ConsumerWidget {
  const LoyaltyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loyaltyAsync = ref.watch(loyaltyProvider);
    final transactionsAsync = ref.watch(loyaltyTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
        title: const Text('Hạng & Điểm thưởng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(loyaltyProvider);
          ref.invalidate(loyaltyTransactionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              loyaltyAsync.when(
                data: (loyalty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE5B94E), Color(0xFFC78B12)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFC78B12).withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.stars, color: Colors.white, size: 48),
                        const SizedBox(height: 8),
                        Text(loyalty.tierName.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Số điểm hiện tại', style: TextStyle(color: Colors.white70)),
                                const SizedBox(height: 4),
                                Text('${loyalty.pointsBalance}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Rửa xe (Chu kỳ)', style: TextStyle(color: Colors.white70)),
                                const SizedBox(height: 4),
                                Text('${loyalty.successfulWashesTowardVoucher}/10', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: loyalty.successfulWashesTowardVoucher / 10.0,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Còn 10 lần nữa để nhận Voucher Miễn phí', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Lỗi tải thông tin hạng: $e')),
              ),
              
              const SizedBox(height: 32),
              const Text('Lịch sử giao dịch điểm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 16),
              
              transactionsAsync.when(
                data: (response) {
                  if (response.items.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Chưa có giao dịch điểm nào', style: TextStyle(color: AppColors.textMedium)),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: response.items.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final t = response.items[index];
                      final isPositive = t.points > 0 || t.type == 'earn';
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: isPositive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          child: Icon(isPositive ? Icons.add : Icons.remove, color: isPositive ? Colors.green : Colors.red),
                        ),
                        title: Text(t.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          t.createdAt.isNotEmpty ? DateTime.parse(t.createdAt).toLocal().toString().substring(0, 16) : 'Không xác định'
                        ),
                        trailing: Text(
                          '${isPositive ? '+' : ''}${t.points} điểm',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isPositive ? Colors.green : Colors.red),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Lỗi tải lịch sử: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
