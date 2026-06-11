import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:wave/features/auth/presentation/providers/auth_controller.dart';
import 'package:wave/features/washer/presentation/pages/washer_profile_page.dart';
import 'package:wave/features/washer/presentation/widgets/washer_badges.dart';

class WasherSettingsPage extends ConsumerStatefulWidget {
  const WasherSettingsPage({super.key});

  @override
  ConsumerState<WasherSettingsPage> createState() => _WasherSettingsPageState();
}

class _WasherSettingsPageState extends ConsumerState<WasherSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.asData?.value?.user;
    final userName = user?.name ?? 'Thợ rửa xe';

    return Scaffold(
      backgroundColor: washerBg,
      appBar: AppBar(
        backgroundColor: washerBg,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Cài đặt',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          _ProfileHeader(name: userName, role: 'Thợ rửa xe'),
          const SizedBox(height: 24),
          const _SectionLabel('TÀI KHOẢN'),
          _Card(
            children: [
              _Tile(
                icon: Icons.person_outline_rounded,
                title: 'Thông tin cá nhân',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WasherProfilePage()),
                ),
              ),
              const _CardDivider(),
              _Tile(
                icon: Icons.lock_outline_rounded,
                title: 'Thay đổi mật khẩu',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 28),
          _LogoutButton(onTap: () => _confirmLogout(context)),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
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
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) context.goNamed('landing');
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String role;
  const _ProfileHeader({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'W',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      size: 15,
                      color: AppColors.textMedium,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      role,
                      style: const TextStyle(color: AppColors.textMedium),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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

class _CardDivider extends StatelessWidget {
  const _CardDivider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 56, color: AppColors.divider);
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _Tile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textLight,
        size: 20,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primaryBlue,
      secondary: Icon(icon, color: AppColors.primaryBlue),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final bool dark;
  final ValueChanged<bool> onChanged;
  const _ThemeTile({required this.dark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.brightness_6_outlined,
        color: AppColors.primaryBlue,
      ),
      title: const Text(
        'Chế độ giao diện',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _opt(
              'Sáng',
              Icons.wb_sunny_outlined,
              !dark,
              () => onChanged(false),
            ),
            _opt('Tối', Icons.nightlight_round, dark, () => onChanged(true)),
          ],
        ),
      ),
    );
  }

  Widget _opt(String label, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? AppColors.primaryBlue : AppColors.textLight,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.textDark : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text('Đăng xuất'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFDECEC),
          foregroundColor: const Color(0xFFE5484D),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
