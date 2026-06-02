import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:wave/features/booking/presentation/providers/booking_data_provider.dart';
import 'package:wave/features/booking/presentation/providers/booking_provider.dart';

class StepTime extends ConsumerWidget {
  const StepTime({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider);
    final bookingNotifier = ref.read(bookingProvider.notifier);
    
    // Default to today if not selected
    final selectedDate = bookingState.selectedDate ?? DateTime.now().toIso8601String().split('T')[0];
    
    // We only fetch slots if a service is selected (should be true if we reached this step)
    final slotsAsync = bookingState.selectedService != null 
        ? ref.watch(availableSlotsProvider((serviceId: bookingState.selectedService!.id, date: selectedDate)))
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Chọn thời gian',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
        ),
        
        // Date Selector (simple horizontal list for next 7 days)
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final dateString = date.toIso8601String().split('T')[0];
              final isSelected = selectedDate == dateString;
              
              return GestureDetector(
                onTap: () => bookingNotifier.selectDate(dateString),
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlue : Colors.white,
                    border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}/${date.month}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        index == 0 ? 'Hôm nay' : 'Th ${date.weekday + 1}',
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : AppColors.textMedium,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Slots grid
        Expanded(
          child: slotsAsync != null
              ? slotsAsync.when(
                  data: (slots) {
                    if (slots.isEmpty) {
                      return const Center(child: Text('Không có khung giờ nào trống', style: TextStyle(color: AppColors.textMedium)));
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: slots.length,
                      itemBuilder: (context, index) {
                        final slot = slots[index];
                        final isSelected = bookingState.selectedSlot?.scheduledAt == slot.scheduledAt;
                        
                        // Parse time HH:mm
                        final timeString = DateTime.parse(slot.scheduledAt).toLocal();
                        final displayTime = '${timeString.hour.toString().padLeft(2, '0')}:${timeString.minute.toString().padLeft(2, '0')}';

                        return GestureDetector(
                          onTap: slot.remainingCapacity > 0 ? () => bookingNotifier.selectSlot(slot) : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : slot.remainingCapacity > 0
                                      ? (slot.isGoldenHour ? AppColors.tierGold.withValues(alpha: 0.1) : Colors.white)
                                      : Colors.grey[200],
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : slot.remainingCapacity > 0
                                        ? (slot.isGoldenHour ? AppColors.tierGold : Colors.grey[300]!)
                                        : Colors.grey[300]!,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              displayTime,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : slot.remainingCapacity > 0
                                        ? (slot.isGoldenHour ? AppColors.tierGold : AppColors.textDark)
                                        : Colors.grey,
                                fontWeight: FontWeight.bold,
                                decoration: slot.remainingCapacity > 0 ? TextDecoration.none : TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => const Center(child: Text('Đã có lỗi xảy ra')),
                )
              : const SizedBox(),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: bookingState.selectedSlot != null
                  ? () => bookingNotifier.nextStep()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Tiếp Tục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }
}
