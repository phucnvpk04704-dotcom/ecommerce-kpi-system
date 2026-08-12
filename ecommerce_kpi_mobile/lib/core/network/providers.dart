import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/employee_repository.dart';
import '../../data/repositories/revenue_repository.dart';
import '../../data/repositories/reward_repository.dart';
import '../../data/repositories/blacklist_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/kpi_repository.dart';
import '../theme/app_router.dart'; // contains secureStorageProvider and authStateProvider
import 'api_client.dart';

// Dio ApiClient Provider with auto-logout behavior on 401 Unauthorized
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(
    storageService: storage,
    onUnauthorized: () {
      // Auto-logout: revert auth state and GoRouter will redirect to /login
      ref.read(authStateProvider.notifier).state = false;
    },
  );
});

// Authentication Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(apiClient: client, storageService: storage);
});

// Dashboard Repository
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return DashboardRepositoryImpl(apiClient: client);
});

// Employee Repository
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return EmployeeRepositoryImpl(apiClient: client);
});

// Revenue Repository
final revenueRepositoryProvider = Provider<RevenueRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return RevenueRepositoryImpl(apiClient: client);
});

// Reward Repository
final rewardRepositoryProvider = Provider<RewardRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return RewardRepositoryImpl(apiClient: client);
});

// Blacklist Repository
final blacklistRepositoryProvider = Provider<BlacklistRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return BlacklistRepositoryImpl(apiClient: client);
});

// Notification Repository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return NotificationRepositoryImpl(apiClient: client);
});

// Settings Repository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return SettingsRepositoryImpl(apiClient: client);
});

// KPI Repository
final kpiRepositoryProvider = Provider<KpiRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return KpiRepositoryImpl(apiClient: client);
});

final kpiSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final kpiRepo = ref.watch(kpiRepositoryProvider);
  return await kpiRepo.getKpiSummary();
});

// --- Async Notifiers to replace simple mock FutureProviders ---

// Dashboard consolidated KPI overview data
class KpiOverviewNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    final dashboardRepo = ref.watch(dashboardRepositoryProvider);
    final summary = await dashboardRepo.getSummary();
    
    double avgKpi = 88.5;
    try {
      final employees = await ref.read(employeeRepositoryProvider).getEmployees();
      if (employees.isNotEmpty) {
        double sum = 0.0;
        for (var emp in employees) {
          sum += ((emp['kpi'] ?? 0.0) as num).toDouble();
        }
        avgKpi = sum / employees.length;
      }
    } catch (_) {}

    return {
      'total_revenue': double.tryParse(summary['total_revenue']?.toString() ?? '') ?? 0.0,
      'revenue_target': 6500000000.0, // target benchmark for visual gauge
      'average_kpi': avgKpi,
      'rewards_distributed': summary['active_sessions'] ?? 0,
      'blacklisted_count': summary['blacklisted_customers'] ?? 0,
      'active_employees': summary['total_employees'] ?? 0,
    };
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final kpiOverviewProvider = AsyncNotifierProvider<KpiOverviewNotifier, Map<String, dynamic>>(KpiOverviewNotifier.new);

// Revenue overview chart data
class RevenuesNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final dashboardRepo = ref.watch(dashboardRepositoryProvider);
    final chartData = await dashboardRepo.getRevenueChart();
    
    return chartData.map((item) {
      final dateStr = item['date']?.toString() ?? '';
      String month = dateStr;
      if (dateStr.length >= 10) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          month = '${parts[2]}/${parts[1]}'; // Day/Month formatted
        }
      }
      final rev = double.tryParse(item['revenue']?.toString() ?? '') ?? 0.0;
      return {
        'month': month,
        'revenue': rev,
        'target': rev * 1.1, // mock comparison benchmark
      };
    }).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final revenuesProvider = AsyncNotifierProvider<RevenuesNotifier, List<Map<String, dynamic>>>(RevenuesNotifier.new);

// Employees KPI Directory supporting CRUD actions
class EmployeesKPINotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repo = ref.watch(employeeRepositoryProvider);
    final employees = await repo.getEmployees();
    
    return employees.map((emp) {
      return {
        'id': emp['id'] ?? '',
        'name': emp['full_name'] ?? '',
        'username': emp['username'] ?? '',
        'email': emp['email'] ?? '',
        'department': emp['department'] ?? 'Marketing',
        'role': emp['role'] ?? 'Employee',
        'status': emp['status'] ?? 'Active',
        'kpi': ((emp['kpi'] ?? 85.0) as num).toDouble(),
        'sales': double.tryParse(emp['sales']?.toString() ?? '') ?? 0.0,
        'avatar': emp['avatar'] ?? (emp['full_name'] != null && emp['full_name'].toString().isNotEmpty 
            ? emp['full_name'].toString().substring(0, 2).toUpperCase() 
            : 'EM'),
      };
    }).toList();
  }

  Future<void> createEmployee(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(employeeRepositoryProvider).createEmployee(data);
      return build();
    });
  }

  Future<void> updateEmployee(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(employeeRepositoryProvider).updateEmployee(id, data);
      return build();
    });
  }

  Future<void> deleteEmployee(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(employeeRepositoryProvider).deleteEmployee(id);
      return build();
    });
  }
}

final employeesKPIProvider = AsyncNotifierProvider<EmployeesKPINotifier, List<Map<String, dynamic>>>(EmployeesKPINotifier.new);

// Rewards and achievement logs
class RewardsListNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repo = ref.watch(rewardRepositoryProvider);
    final list = await repo.getRewards();
    return list.map((item) {
      return {
        'id': item['id'] ?? '',
        'title': item['title'] ?? 'KPI Milestone Achieved',
        'description': item['description'] ?? 'Reward for target completion',
        'reward': '${item['reward_amount'] ?? "0.00"} ${item['currency'] ?? "VND"}',
        'status': item['status'] ?? 'Active',
        'date': item['date'] ?? '',
      };
    }).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final rewardsListProvider = AsyncNotifierProvider<RewardsListNotifier, List<Map<String, dynamic>>>(RewardsListNotifier.new);

// Blacklisted Customer profiles
class BlacklistNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repo = ref.watch(blacklistRepositoryProvider);
    final list = await repo.getBlacklist();
    return list.map((item) {
      final total = ((item['total_orders'] ?? 0) as num).toDouble();
      final cancelled = ((item['cancelled_orders'] ?? 0) as num).toDouble();
      final rate = total > 0 ? (cancelled / total * 100.0) : 0.0;
      return {
        'id': item['id'] ?? '',
        'name': item['customer_name'] ?? 'Unknown Customer',
        'phone': item['customer_phone'] ?? '',
        'reason': item['reason'] ?? 'High cancellation rates detected',
        'date': item['added_at'] != null ? item['added_at'].toString().split('T')[0] : '',
        'risk': item['risk_level'] ?? 'Medium',
        'cancellationRate': rate,
      };
    }).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final blacklistProvider = AsyncNotifierProvider<BlacklistNotifier, List<Map<String, dynamic>>>(BlacklistNotifier.new);

// Leaderboard calculated directly from real employee KPI score metric rankings
class LeaderboardNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final employees = await ref.watch(employeeRepositoryProvider).getEmployees();
    final list = List<Map<String, dynamic>>.from(employees);
    
    // Sort employees by KPI score descending
    list.sort((a, b) {
      final double kpiA = ((a['kpi'] ?? 0.0) as num).toDouble();
      final double kpiB = ((b['kpi'] ?? 0.0) as num).toDouble();
      return kpiB.compareTo(kpiA);
    });
    
    // Assign rankings sequential values
    for (int i = 0; i < list.length; i++) {
      list[i] = {
        'id': list[i]['id'] ?? '',
        'rank': i + 1,
        'name': list[i]['full_name'] ?? '',
        'kpi': ((list[i]['kpi'] ?? 0.0) as num).toDouble(),
        'sales': double.tryParse(list[i]['sales']?.toString() ?? '') ?? 0.0,
        'avatar': list[i]['avatar'] ?? (list[i]['full_name'] != null && list[i]['full_name'].toString().isNotEmpty 
            ? list[i]['full_name'].toString().substring(0, 2).toUpperCase() 
            : 'EM'),
      };
    }
    return list;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

final leaderboardProvider = AsyncNotifierProvider<LeaderboardNotifier, List<Map<String, dynamic>>>(LeaderboardNotifier.new);

// Alerts and System Notifications
class NotificationsNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repo = ref.watch(notificationRepositoryProvider);
    final list = await repo.getNotifications();
    return list.map((item) {
      return {
        'id': item['id'] ?? '',
        'title': item['title'] ?? '',
        'body': item['body'] ?? '',
        'time': item['created_at'] != null ? item['created_at'].toString().split('T')[0] : 'Just now',
        'type': item['type']?.toString().toLowerCase() ?? 'info',
        'read': item['is_read'] ?? false,
      };
    }).toList();
  }

  Future<void> markAsRead(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(notificationRepositoryProvider).markAsRead(id);
      return build();
    });
  }
}

final notificationsProvider = AsyncNotifierProvider<NotificationsNotifier, List<Map<String, dynamic>>>(NotificationsNotifier.new);

// Configuration Settings Provider
class SettingsListNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repo = ref.watch(settingsRepositoryProvider);
    return await repo.getSettings();
  }

  Future<void> updateSetting(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(settingsRepositoryProvider).updateSetting(id, data);
      return build();
    });
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsListNotifier, List<Map<String, dynamic>>>(SettingsListNotifier.new);
