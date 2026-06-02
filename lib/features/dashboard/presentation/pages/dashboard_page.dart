import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:wave/features/auth/presentation/providers/auth_controller.dart';
import 'package:wave/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:wave/features/profile/presentation/widgets/loyalty_card.dart';
import 'package:wave/features/profile/presentation/widgets/quick_actions_grid.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value?.user;
    final userName = user?.name ?? 'Thành viên';
    final userEmail = user?.email ?? '';

    final loyaltyAsync = ref.watch(loyaltyProvider);
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            backgroundColor: AppColors.darkBlue,
            foregroundColor: AppColors.white,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const Icon(Icons.waves_rounded, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'WAVE',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Greeting(name: userName),
                  const SizedBox(height: 20),
                  loyaltyAsync.when(
                    data: (loyalty) => LoyaltyCard(
                      name: userName,
                      email: userEmail,
                      loyaltyPoints: loyalty.pointsBalance.toInt(),
                      tier: loyalty.tierName.toUpperCase(),
                      progress: loyalty.successfulWashesTowardVoucher / 10.0,
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => LoyaltyCard(
                      name: userName,
                      email: userEmail,
                      loyaltyPoints: 0,
                      tier: 'NONE',
                      progress: 0.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionHeader(title: 'Thao Tác Nhanh'),
                  const SizedBox(height: 14),
                  const QuickActionsGrid(),
                  const SizedBox(height: 24),
                  const _SectionHeader(title: 'Dịch Vụ Nổi Bật'),
                  const SizedBox(height: 14),
                  servicesAsync.when(
                    data: (services) => SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: services.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return GestureDetector(
                            onTap: () {
                              // If you want to pre-select, you can call bookingNotifier.selectService(service) here
                              // But for now, we just go to the booking page
                              context.go('/booking');
                            },
                            child: Container(
                              width: 140,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.local_car_wash, color: AppColors.primaryBlue),
                                  const SizedBox(height: 12),
                                  Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const Spacer(),
                                  Text('${service.basePrice}đ', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => const Text('Lỗi tải danh sách dịch vụ'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.primaryGradient,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  final String name;
  const _Greeting({required this.name});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Chào buổi sáng,'
        : hour < 17
            ? 'Chào buổi chiều,'
            : 'Chào buổi tối,';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(fontSize: 15, color: AppColors.textMedium),
        ),
        const SizedBox(height: 2),
        Text(
          name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
