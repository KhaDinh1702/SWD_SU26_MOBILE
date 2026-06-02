import 'package:wave/features/auth/presentation/pages/login_page.dart';
import 'package:wave/features/auth/presentation/pages/register_page.dart';
import 'package:wave/features/booking/presentation/pages/booking_page.dart';
import 'package:wave/features/booking/presentation/pages/payment_webview_page.dart';
import 'package:wave/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wave/features/history/presentation/pages/history_page.dart';
import 'package:wave/features/home/presentation/pages/home_page.dart';
import 'package:wave/features/profile/presentation/pages/profile_page.dart';
import 'package:wave/features/shell/presentation/pages/main_shell.dart';
import 'package:wave/features/profile/presentation/pages/vehicles_page.dart' as wave_vehicles;
import 'package:wave/features/profile/presentation/pages/vouchers_page.dart' as wave_vouchers;
import 'package:wave/features/profile/presentation/pages/loyalty_page.dart' as wave_loyalty;
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    // Splash / auth — không có bottom nav
    GoRoute(
      path: '/',
      name: 'landing',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/payment',
      name: 'payment',
      builder: (context, state) {
        final url = state.extra as String? ?? '';
        return PaymentWebViewPage(checkoutUrl: url);
      },
    ),
    // Profile Sub-pages (No Bottom Nav)
    GoRoute(
      path: '/vehicles',
      name: 'vehicles',
      builder: (context, state) => const wave_vehicles.VehiclesPage(),
    ),
    GoRoute(
      path: '/vouchers',
      name: 'vouchers',
      builder: (context, state) => const wave_vouchers.VouchersPage(),
    ),
    GoRoute(
      path: '/loyalty',
      name: 'loyalty',
      builder: (context, state) => const wave_loyalty.LoyaltyPage(),
    ),

    // Shell — bottom nav hiển thị sau khi login
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home-dashboard',
              name: 'dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/booking',
              name: 'booking',
              builder: (context, state) => const BookingPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              name: 'history',
              builder: (context, state) => const HistoryPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/me',
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
