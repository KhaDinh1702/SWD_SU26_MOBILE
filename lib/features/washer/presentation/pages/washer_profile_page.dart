import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:wave/features/auth/data/models/user_model.dart';
import 'package:wave/features/auth/presentation/providers/auth_controller.dart';
import 'package:wave/features/washer/presentation/widgets/washer_badges.dart';

class WasherProfilePage extends ConsumerWidget {
  const WasherProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value?.user;

    return Scaffold(
      backgroundColor: washerBg,
      appBar: AppBar(
        backgroundColor: washerBg,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: user == null
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _Avatar(name: user.name),
                const SizedBox(height: 24),
                const _SectionLabel('THÔNG TIN TÀI KHOẢN'),
                _Card(
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Họ và tên',
                      value: user.name.isNotEmpty ? user.name : '—',
                    ),
                    const _Divider(),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user.email.isNotEmpty ? user.email : '—',
                    ),
                    const _Divider(),
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Vai trò',
                      value: _roleLabel(user),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  String _roleLabel(UserModel user) {
    if (user.isWasher) return 'Thợ rửa xe';
    return user.role.isNotEmpty ? user.role : 'Người dùng';
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: 44,
        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'W',
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 10),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textLight,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 56, color: AppColors.divider);
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.textMedium,
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Chưa có thông tin tài khoản',
        style: TextStyle(color: AppColors.textMedium),
      ),
    );
  }
}
