import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:wave/features/washer/data/models/washer_order_model.dart';
import 'package:wave/features/washer/presentation/pages/washer_detail_page.dart';
import 'package:wave/features/washer/presentation/providers/washer_provider.dart';
import 'package:wave/features/washer/presentation/widgets/washer_badges.dart';

class WasherDashboardPage extends ConsumerStatefulWidget {
  const WasherDashboardPage({super.key});

  @override
  ConsumerState<WasherDashboardPage> createState() =>
      _WasherDashboardPageState();
}

class _WasherDashboardPageState extends ConsumerState<WasherDashboardPage> {
  bool _isDone(WasherOrderModel o) => o.isCompleted;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(washerWorkOrdersProvider);

    return Scaffold(
      backgroundColor: washerBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              countText: ordersAsync.maybeWhen(
                data: (orders) {
                  final pending = orders.where((o) => !_isDone(o)).length;
                  return 'Hôm nay bạn có $pending xe cần xử lý';
                },
                orElse: () => 'Đang tải công việc...',
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ordersAsync.when(
                data: (orders) {
                  final filtered =
                      orders.where((o) => !_isDone(o)).toList();
                  if (filtered.isEmpty) {
                    return const _EmptyState(
                      text: 'Không có xe nào cần xử lý',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(washerWorkOrdersProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: filtered.length,
                      separatorBuilder: (_, i) => const SizedBox(height: 16),
                      itemBuilder: (context, i) => _WorkOrderCard(
                        order: filtered[i],
                        onDetail: () => _openDetail(filtered[i]),
                        onStart: () => _startWork(filtered[i]),
                      ),
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => _EmptyState(
                  text: 'Không tải được danh sách công việc',
                  onRetry: () => ref.invalidate(washerWorkOrdersProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(WasherOrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WasherDetailPage(order: order)),
    );
  }

  /// Bấm "Bắt đầu làm việc": gọi API start (nếu đang chờ) rồi mở chi tiết.
  Future<void> _startWork(WasherOrderModel order) async {
    var current = order;
    if (order.isWaiting) {
      try {
        current =
            await ref.read(washerRepositoryProvider).startWorkOrder(order.id);
        ref.invalidate(washerWorkOrdersProvider);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không bắt đầu được công việc')),
          );
        }
      }
    }
    if (mounted) _openDetail(current);
  }
}

class _Header extends StatelessWidget {
  final String countText;
  const _Header({required this.countText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lịch làm việc của tôi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  countText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded,
                color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}

class _WorkOrderCard extends StatelessWidget {
  final WasherOrderModel order;
  final VoidCallback onDetail;
  final VoidCallback onStart;
  const _WorkOrderCard({
    required this.order,
    required this.onDetail,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LicensePlateChip(
                  plate: order.licensePlate.isEmpty ? '—' : order.licensePlate),
              WorkStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 14),
          if (order.serviceName.isNotEmpty)
            Text(
              order.serviceName.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            order.vehicleLabel,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.place_outlined,
                  size: 16, color: AppColors.textLight),
              const SizedBox(width: 6),
              Text(
                order.stationName.isEmpty ? 'Chưa phân khu' : order.stationName,
                style: const TextStyle(color: AppColors.textMedium, fontSize: 13),
              ),
              if (order.estimatedMinutes > 0) ...[
                const SizedBox(width: 12),
                const Icon(Icons.timer_outlined,
                    size: 16, color: AppColors.textLight),
                const SizedBox(width: 6),
                Text(
                  '~${order.estimatedMinutes} phút',
                  style: const TextStyle(
                      color: AppColors.textMedium, fontSize: 13),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDetail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Chi tiết',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onStart,
                  child: const Text('Bắt đầu làm việc'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  final VoidCallback? onRetry;
  const _EmptyState({required this.text, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_car_wash_outlined,
              size: 64, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(color: AppColors.textMedium)),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ],
      ),
    );
  }
}
