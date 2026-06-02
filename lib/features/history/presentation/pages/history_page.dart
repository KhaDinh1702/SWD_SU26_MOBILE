import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:wave/features/history/presentation/providers/history_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.darkBlue,
          foregroundColor: AppColors.white,
          automaticallyImplyLeading: false,
          title: const Text(
            'Lịch Sử Đặt Lịch',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.tierGold,
            tabs: [
              Tab(text: 'Sắp tới'),
              Tab(text: 'Lịch sử'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrdersList(isPast: false),
            _OrdersList(isPast: true),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final bool isPast;
  const _OrdersList({required this.isPast});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return ordersAsync.when(
      data: (orders) {
        // Filter orders
        final filtered = orders.where((o) {
          final isCompletedOrCancelled = o.status == 'completed' || o.status == 'cancelled' || o.status == 'no_show';
          return isPast ? isCompletedOrCancelled : !isCompletedOrCancelled;
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isPast ? Icons.history : Icons.calendar_today, size: 64, color: AppColors.textMedium),
                const SizedBox(height: 16),
                Text(isPast ? 'Không có lịch sử nào' : 'Bạn chưa có lịch hẹn nào sắp tới', style: const TextStyle(color: AppColors.textMedium)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: filtered.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final order = filtered[index];
            final t = DateTime.parse(order.scheduledAt).toLocal();
            final displayTime = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} - ${t.day}/${t.month}/${t.year}';
            
            Color statusColor;
            String statusText;
            switch(order.status) {
              case 'pending_payment': statusColor = Colors.orange; statusText = 'Chờ thanh toán'; break;
              case 'confirmed': statusColor = AppColors.primaryBlue; statusText = 'Đã xác nhận'; break;
              case 'checked_in': statusColor = Colors.purple; statusText = 'Đã đến'; break;
              case 'in_progress': statusColor = AppColors.tierGold; statusText = 'Đang rửa'; break;
              case 'completed': statusColor = Colors.green; statusText = 'Hoàn thành'; break;
              case 'cancelled': statusColor = Colors.red; statusText = 'Đã hủy'; break;
              case 'no_show': statusColor = Colors.grey; statusText = 'Không đến'; break;
              default: statusColor = Colors.grey; statusText = order.status;
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(displayTime, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.local_car_wash, color: AppColors.textMedium, size: 20),
                      const SizedBox(width: 8),
                      Text(order.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.directions_car, color: AppColors.textMedium, size: 20),
                      const SizedBox(width: 8),
                      Text(order.licensePlate, style: const TextStyle(color: AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Thanh toán: ${order.paymentMethod == 'online' ? 'Chuyển khoản' : 'Tiền mặt'}', style: const TextStyle(color: AppColors.textMedium, fontSize: 13)),
                      Text('${order.amount}đ', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Center(child: Text('Đã có lỗi xảy ra')),
    );
  }
}
