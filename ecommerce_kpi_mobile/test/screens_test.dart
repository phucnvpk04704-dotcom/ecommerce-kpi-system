import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce_kpi_mobile/main.dart';
import 'package:ecommerce_kpi_mobile/core/theme/app_router.dart';
import 'package:ecommerce_kpi_mobile/core/network/providers.dart';
import 'package:ecommerce_kpi_mobile/data/services/secure_storage_service.dart';
import 'package:ecommerce_kpi_mobile/data/repositories/auth_repository.dart';
import 'package:ecommerce_kpi_mobile/data/repositories/dashboard_repository.dart';
import 'package:ecommerce_kpi_mobile/data/repositories/employee_repository.dart';
import 'package:ecommerce_kpi_mobile/data/repositories/revenue_repository.dart';
import 'package:ecommerce_kpi_mobile/data/repositories/reward_repository.dart';
import 'package:ecommerce_kpi_mobile/data/repositories/blacklist_repository.dart';
import 'package:ecommerce_kpi_mobile/data/repositories/notification_repository.dart';
import 'package:ecommerce_kpi_mobile/data/repositories/settings_repository.dart';

// Sync Mock implementations for testing
class MockSecureStorage extends SecureStorageService {
  @override
  Future<String?> readToken() async => 'mock_token';
  @override
  Future<String?> readUser() async => '{"name":"Admin","email":"admin@ecommercekpi.com","role":"Admin","department":"Management"}';
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<String> login({required String username, required String password}) async => 'mock_token';
  @override
  Future<void> logout() async {}
  @override
  Future<Map<String, dynamic>?> getCurrentUser() async => {'name': 'Admin', 'role': 'Admin', 'email': 'admin@ecommercekpi.com'};
  @override
  Future<bool> isAuthenticated() async => true;
}

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<Map<String, dynamic>> getSummary() async => {
    "total_orders": 5000,
    "total_revenue": "6021561504.36",
    "total_employees": 20,
    "active_sessions": 9,
    "total_notifications": 100,
    "blacklisted_customers": 100
  };
  @override
  Future<Map<String, dynamic>> getKpi() async => {
    "orders_today": 36,
    "revenue_today": "46637076.47",
    "active_users_today": 3,
    "growth_rate": -0.155
  };
  @override
  Future<List<Map<String, dynamic>>> getRevenueChart() async => [
    {"date": "2026-05-24", "revenue": "67130176.26"}
  ];
  @override
  Future<List<Map<String, dynamic>>> getOrdersChart() async => [
    {"date": "2026-05-24", "order_count": 55}
  ];
  @override
  Future<Map<String, dynamic>> getRecentActivities() async => {
    "recent_orders": []
  };
}

class MockEmployeeRepository implements EmployeeRepository {
  @override
  Future<List<Map<String, dynamic>>> getEmployees({int skip = 0, int limit = 100}) async => [
    {"id": "1", "full_name": "Alice Smith", "username": "alice", "email": "alice@ecommercekpi.com", "department": "Marketing", "role": "Employee", "status": "Active", "kpi": 95.0, "sales": 10000.0}
  ];
  @override
  Future<Map<String, dynamic>> createEmployee(Map<String, dynamic> data) async => {};
  @override
  Future<Map<String, dynamic>> updateEmployee(String id, Map<String, dynamic> data) async => {};
  @override
  Future<Map<String, dynamic>> deleteEmployee(String id) async => {};
}

class MockRevenueRepository implements RevenueRepository {
  @override
  Future<List<Map<String, dynamic>>> getRevenues({int skip = 0, int limit = 100}) async => [];
  @override
  Future<Map<String, dynamic>> getEmployeeRevenueStats(String employeeId, {required String platform, required String startDate, required String endDate}) async => {};
}

class MockRewardRepository implements RewardRepository {
  @override
  Future<List<Map<String, dynamic>>> getRewards({int skip = 0, int limit = 100}) async => [];
  @override
  Future<List<Map<String, dynamic>>> getEmployeeRewardHistory(String employeeId, {required String startDate, required String endDate}) async => [];
}

class MockBlacklistRepository implements BlacklistRepository {
  @override
  Future<List<Map<String, dynamic>>> getBlacklist({int skip = 0, int limit = 100}) async => [];
  @override
  Future<Map<String, dynamic>> addBlacklistEntry(Map<String, dynamic> data) async => {};
  @override
  Future<Map<String, dynamic>> findByPhone(String phone) async => {};
  @override
  Future<Map<String, dynamic>> removeBlacklistEntry(String id) async => {};
}

class MockNotificationRepository implements NotificationRepository {
  @override
  Future<List<Map<String, dynamic>>> getNotifications({int skip = 0, int limit = 100}) async => [];
  @override
  Future<Map<String, dynamic>> markAsRead(String id) async => {};
}

class MockSettingsRepository implements SettingsRepository {
  @override
  Future<List<Map<String, dynamic>>> getSettings({int skip = 0, int limit = 100}) async => [];
  @override
  Future<Map<String, dynamic>> getSettingByKey(String key) async => {};
  @override
  Future<Map<String, dynamic>> updateSetting(String id, Map<String, dynamic> data) async => {};
}

void main() {
  testWidgets('All feature screens render successfully when authenticated', (WidgetTester tester) async {
    // Build our app and trigger a frame with authStateProvider overridden to true
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => true),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          dashboardRepositoryProvider.overrideWithValue(MockDashboardRepository()),
          employeeRepositoryProvider.overrideWithValue(MockEmployeeRepository()),
          revenueRepositoryProvider.overrideWithValue(MockRevenueRepository()),
          rewardRepositoryProvider.overrideWithValue(MockRewardRepository()),
          blacklistRepositoryProvider.overrideWithValue(MockBlacklistRepository()),
          notificationRepositoryProvider.overrideWithValue(MockNotificationRepository()),
          settingsRepositoryProvider.overrideWithValue(MockSettingsRepository()),
        ],
        child: const MyApp(),
      ),
    );

    // Let the initial route settle (which will be /dashboard)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Dashboard screen is active
    expect(find.text('Enterprise Dashboard'), findsAtLeastNWidgets(1));

    final BuildContext context = rootNavigatorKey.currentContext!;
    final router = GoRouter.of(context);

    // Helper function to test routing and rendering without hanging on infinite animations
    Future<void> testRoute(String path, String expectedText) async {
      router.go(path);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(expectedText), findsAtLeastNWidgets(1));
    }

    // 1. Employees screen
    await testRoute('/employees', 'Team Performance');

    // 2. KPI screen
    await testRoute('/kpi', 'Store KPI Performance');

    // 3. Rewards screen
    await testRoute('/rewards', 'Company Rewards');

    // 4. Notifications screen
    await testRoute('/notifications', 'Notifications Center');

    // 5. Profile screen
    await testRoute('/profile', 'User Profile');

    // 6. More screen
    await testRoute('/more', 'More');
  });
}
