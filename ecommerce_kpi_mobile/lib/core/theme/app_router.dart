import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/secure_storage_service.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/employees/employees_screen.dart';
import '../../features/kpi/kpi_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/rewards/rewards_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/leaderboard/leaderboard_screen.dart';
import '../../screens/blacklist_screen.dart';
import '../../screens/blacklist_detail_screen.dart';
import '../../screens/blacklist_create_screen.dart';
import '../../screens/blacklist_edit_screen.dart';
import '../../features/employees/employee_detail_screen.dart';
import '../../screens/report_screen.dart';
import '../../screens/report_detail_screen.dart';
import '../../screens/settings_screen.dart';

// Key for accessing navigator state globally
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final authStateProvider = StateProvider<bool>((ref) {
  // Simple state provider to track if the user is authenticated in memory.
  // Real implementations will read/write using secure storage.
  return false;
});

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      
      // If the user is not authenticated, they must be redirected to /login
      if (!authState) {
        return isLoggingIn ? null : '/login';
      }

      // If the user is authenticated and trying to go to /login, redirect to /dashboard
      if (isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/employees',
        builder: (context, state) => const EmployeesScreen(),
      ),
      GoRoute(
        path: '/kpi',
        builder: (context, state) => const KpiScreen(),
      ),
      GoRoute(
        path: '/rewards',
        builder: (context, state) => const RewardsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/more',
        builder: (context, state) => const MoreScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/blacklist',
        builder: (context, state) => const BlacklistScreen(),
      ),
      GoRoute(
        path: '/blacklist_screen',
        builder: (context, state) => const BlacklistScreen(),
      ),
      GoRoute(
        path: '/blacklist_detail_screen/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlacklistDetailScreen(customerId: id);
        },
      ),
      GoRoute(
        path: '/blacklist_create_screen',
        builder: (context, state) => const BlacklistCreateScreen(),
      ),
      GoRoute(
        path: '/blacklist_edit_screen/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlacklistEditScreen(customerId: id);
        },
      ),
      GoRoute(
        path: '/employees/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EmployeeDetailScreen(employeeId: id);
        },
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportScreen(),
      ),
      GoRoute(
        path: '/report_screen',
        builder: (context, state) => const ReportScreen(),
      ),
      GoRoute(
        path: '/report_detail_screen/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReportDetailScreen(reportId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings_screen',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

