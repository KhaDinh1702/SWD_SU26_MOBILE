import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:wave/features/booking/presentation/providers/booking_provider.dart';
import 'package:wave/features/booking/presentation/widgets/step_vehicle.dart';
import 'package:wave/features/booking/presentation/widgets/step_service.dart';
import 'package:wave/features/booking/presentation/widgets/step_time.dart';
import 'package:wave/features/booking/presentation/widgets/step_confirm.dart';

class BookingPage extends ConsumerWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider);
    final bookingNotifier = ref.read(bookingProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Đặt Lịch Rửa Xe',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: bookingState.currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => bookingNotifier.previousStep(),
              )
            : null,
      ),
      body: Column(
        children: [
          // Step progress bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: List.generate(4, (index) {
                final isActive = index <= bookingState.currentStep;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primaryBlue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: _buildStepContent(bookingState.currentStep),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return const StepVehicle();
      case 1:
        return const StepService();
      case 2:
        return const StepTime();
      case 3:
        return const StepConfirm();
      default:
        return const SizedBox();
    }
  }
}
