import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/theme/app_colors.dart';
import 'package:wave/features/washer/presentation/pages/washer_completed_page.dart';
import 'package:wave/features/washer/presentation/pages/washer_dashboard_page.dart';
import 'package:wave/features/washer/presentation/pages/washer_settings_page.dart';
import 'package:wave/features/washer/presentation/providers/washer_provider.dart';

/// Khung điều hướng cho vai trò washer với 3 tab:
/// Công việc · Hoàn thành · Tôi.
class WasherShell extends ConsumerStatefulWidget {
  const WasherShell({super.key});

  @override
  ConsumerState<WasherShell> createState() => _WasherShellState();
}

class _WasherShellState extends ConsumerState<WasherShell>
    with WidgetsBindingObserver {
  int _index = 0;

  static const _pages = [
    WasherDashboardPage(),
    WasherCompletedPage(),
    WasherSettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Mở app lại từ background → tải lại danh sách công việc.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(washerWorkOrdersProvider);
    }
  }

  void _onSelectTab(int i) {
    // Chọn tab có danh sách (Công việc / Hoàn thành) → làm mới dữ liệu.
    if (i == 0 || i == 1) {
      ref.invalidate(washerWorkOrdersProvider);
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _onSelectTab,
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppColors.lightBlue.withValues(alpha: 0.55),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.local_car_wash_outlined),
              selectedIcon:
                  Icon(Icons.local_car_wash_rounded, color: AppColors.primaryBlue),
              label: 'Công việc',
            ),
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline_rounded),
              selectedIcon:
                  Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue),
              label: 'Hoàn thành',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryBlue),
              label: 'Tôi',
            ),
          ],
        ),
      ),
    );
  }
}
