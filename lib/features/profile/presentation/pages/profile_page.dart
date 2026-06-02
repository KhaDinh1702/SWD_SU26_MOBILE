import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:wave/features/auth/presentation/providers/auth_controller.dart';
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
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Tài Khoản',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // User Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                  child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(userEmail, style: const TextStyle(color: AppColors.textMedium)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Text('Quản lý chung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMedium)),
          const SizedBox(height: 12),
          
          _buildMenuItem(icon: Icons.confirmation_num, title: 'Ví Voucher', onTap: () => context.push('/vouchers')),
          _buildMenuItem(icon: Icons.directions_car, title: 'Xe của tôi', onTap: () => context.push('/vehicles')),
          _buildMenuItem(icon: Icons.stars, title: 'Hạng thành viên & Điểm thưởng', onTap: () => context.push('/loyalty')),
          
          const SizedBox(height: 24),
          const Text('Hỗ trợ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMedium)),
          const SizedBox(height: 12),
          
          _buildMenuItem(icon: Icons.help_outline, title: 'Trung tâm trợ giúp', onTap: () {}),
          _buildMenuItem(icon: Icons.info_outline, title: 'Về Wash-Auto', onTap: () {}),
          
          const SizedBox(height: 32),
          LogoutButton(
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Đăng xuất'),
                  content: const Text('Bạn có chắc muốn đăng xuất không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.goNamed('landing');
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))
        ]
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primaryBlue),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textMedium),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
