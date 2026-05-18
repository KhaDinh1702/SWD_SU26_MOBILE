import 'package:flutter_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_app/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_app/features/booking/presentation/pages/booking_page.dart';
import 'package:flutter_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter_app/features/history/presentation/pages/history_page.dart';
import 'package:flutter_app/features/home/presentation/pages/home_page.dart';
import 'package:flutter_app/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_app/features/shell/presentation/pages/main_shell.dart';
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
