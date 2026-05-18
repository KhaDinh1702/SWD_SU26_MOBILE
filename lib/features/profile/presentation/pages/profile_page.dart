import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:wave/features/auth/presentation/providers/auth_controller.dart';
import 'package:wave/features/profile/presentation/widgets/loyalty_card.dart';
import 'package:wave/features/profile/presentation/widgets/quick_actions_grid.dart';
import 'package:wave/features/profile/presentation/widgets/recent_activity_list.dart';
import 'package:wave/features/profile/presentation/widgets/logout_button.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value?.user;
    final userName = user?.name ?? 'Thành viên';
    final userEmail = user?.email ?? '';

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
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
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
                  LoyaltyCard(
                    name: userName,
                    email: userEmail,
                    loyaltyPoints: user != null ? 1250 : 0,
                    tier: 'VÀNG',
                  ),
                  const SizedBox(height: 24),
                  const _SectionHeader(title: 'Thao Tác Nhanh'),
                  const SizedBox(height: 14),
                  const QuickActionsGrid(),
                  const SizedBox(height: 24),
                  const _SectionHeader(title: 'Hoạt Động Gần Đây'),
                  const SizedBox(height: 14),
                  const RecentActivityList(),
                  const SizedBox(height: 24),
                  LogoutButton(
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Đăng xuất'),
                          content: const Text(
                            'Bạn có chắc muốn đăng xuất không?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text(
                                'Đăng xuất',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      await ref
                          .read(authControllerProvider.notifier)
                          .logout();
                      if (context.mounted) context.goNamed('landing');
                    },
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
