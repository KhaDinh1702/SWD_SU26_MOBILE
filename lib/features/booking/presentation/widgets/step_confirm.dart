import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wave/core/providers/customer_provider.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:wave/features/booking/presentation/providers/booking_data_provider.dart';
import 'package:wave/features/booking/presentation/providers/booking_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StepConfirm extends ConsumerWidget {
  const StepConfirm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider);
    final bookingNotifier = ref.read(bookingProvider.notifier);

    // Call preview order API
    final previewAsync = ref.watch(previewOrderProvider((
      serviceId: bookingState.selectedService!.id,
      scheduledAt: bookingState.selectedSlot!.scheduledAt,
      voucherId: bookingState.voucherId,
    )));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Xác nhận thông tin',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
        ),
        
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // Vehicle summary
              _buildSummaryCard(
                icon: Icons.directions_car,
                title: 'Xe',
                value: '${bookingState.selectedVehicle?.brand} ${bookingState.selectedVehicle?.model} - ${bookingState.selectedVehicle?.licensePlate}',
              ),
              const SizedBox(height: 12),
              
              // Service summary
              _buildSummaryCard(
                icon: Icons.local_car_wash,
                title: 'Dịch vụ',
                value: bookingState.selectedService?.name ?? '',
              ),
              const SizedBox(height: 12),
              
              // Time summary
              _buildSummaryCard(
                icon: Icons.access_time,
                title: 'Thời gian',
                value: () {
                  if (bookingState.selectedSlot == null) return '';
                  final t = DateTime.parse(bookingState.selectedSlot!.scheduledAt).toLocal();
                  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} - ${t.day}/${t.month}/${t.year}';
                }(),
              ),
              
              const SizedBox(height: 24),
              const Text('Ghi chú cho cửa hàng', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                onChanged: (val) => bookingNotifier.setNote(val),
                decoration: InputDecoration(
                  hintText: 'Ví dụ: Hút bụi kỹ phần ghế sau...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 24),
              const Text('Phương thức thanh toán', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => bookingNotifier.setPaymentMethod('cash'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: bookingState.paymentMethod == 'cash' ? AppColors.primaryBlue : Colors.white,
                          border: Border.all(color: bookingState.paymentMethod == 'cash' ? AppColors.primaryBlue : Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text('Tiền mặt', style: TextStyle(
                          color: bookingState.paymentMethod == 'cash' ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        )),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => bookingNotifier.setPaymentMethod('online'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: bookingState.paymentMethod == 'online' ? AppColors.primaryBlue : Colors.white,
                          border: Border.all(color: bookingState.paymentMethod == 'online' ? AppColors.primaryBlue : Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text('Chuyển khoản', style: TextStyle(
                          color: bookingState.paymentMethod == 'online' ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        )),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              
              // Price calculations
              previewAsync.when(
                data: (preview) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tạm tính', style: TextStyle(color: AppColors.textMedium)),
                          Text('${preview.originalAmount}đ', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (preview.discountAmount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Giảm giá (${preview.discountReason})', style: const TextStyle(color: Colors.green)),
                              Text('-${preview.discountAmount}đ', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng cộng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${preview.amount}đ', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => const Text('Không thể tải giá', style: TextStyle(color: Colors.red)),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: previewAsync.isLoading 
                ? null 
                : () async {
                  try {
                    // Call API to create order
                    final repo = ref.read(customerRepositoryProvider);
                    final order = await repo.createOrder(
                      vehicleId: bookingState.selectedVehicle!.id,
                      serviceTypeId: bookingState.selectedService!.id,
                      scheduledAt: bookingState.selectedSlot!.scheduledAt,
                      paymentMethod: bookingState.paymentMethod,
                      voucherId: bookingState.voucherId,
                      note: bookingState.note,
                    );
                    
                    if (context.mounted) {
                      bookingNotifier.reset(); // reset state for next time
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đặt lịch thành công!'), backgroundColor: Colors.green),
                      );
                      
                      if (order.paymentMethod == 'online' && order.payosCheckoutUrl.isNotEmpty) {
                        if (context.mounted) {
                          final result = await context.pushNamed<String>('payment', extra: order.payosCheckoutUrl);
                          debugPrint('Payment WebView result: $result');
                        }
                      }
                      
                      if (context.mounted) {
                        context.go('/history'); // switch to history tab
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Xác nhận & Đặt lịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textMedium, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          )
        ],
      ),
    );
  }
}
