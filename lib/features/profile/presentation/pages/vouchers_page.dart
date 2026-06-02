import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:wave/features/profile/presentation/providers/voucher_management_provider.dart';

class VouchersPage extends ConsumerWidget {
  const VouchersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.darkBlue,
          foregroundColor: AppColors.white,
          title: const Text('Ví Voucher', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.tierGold,
            tabs: [
              Tab(text: 'Chưa dùng'),
              Tab(text: 'Đã dùng'),
              Tab(text: 'Hết hạn'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _VoucherList(status: 'unused'),
            _VoucherList(status: 'used'),
            _VoucherList(status: 'expired'),
          ],
        ),
      ),
    );
  }
}

class _VoucherList extends ConsumerWidget {
  final String status;
  const _VoucherList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(vouchersProvider(status));

    return asyncData.when(
      data: (vouchers) {
        if (vouchers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.confirmation_num_outlined, size: 64, color: AppColors.textMedium),
                const SizedBox(height: 16),
                Text(
                  status == 'unused' ? 'Không có voucher nào' : 
                  status == 'used' ? 'Chưa sử dụng voucher nào' : 'Không có voucher hết hạn', 
                  style: const TextStyle(color: AppColors.textMedium)
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: vouchers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final v = vouchers[index];
            final bool isUsable = status == 'unused';
            
            return Container(
              height: 100,
              decoration: BoxDecoration(
                color: isUsable ? Colors.white : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: isUsable ? AppColors.tierGold : Colors.grey[400],
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    ),
                    child: const Center(
                      child: Icon(Icons.local_offer, color: Colors.white, size: 40),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.code, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isUsable ? AppColors.textDark : AppColors.textMedium)),
                          const SizedBox(height: 4),
                          Text('Giảm tối đa ${v.discountCapVnd}đ', style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
                          const Spacer(),
                          Text(
                            'HSD: ${DateTime.parse(v.expiresAt).toLocal().toString().substring(0, 10)}', 
                            style: TextStyle(fontSize: 12, color: isUsable ? Colors.redAccent : AppColors.textMedium)
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi tải dữ liệu: $e')),
    );
  }
}
