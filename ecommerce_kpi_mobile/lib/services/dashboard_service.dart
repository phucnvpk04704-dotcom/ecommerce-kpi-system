import '../core/network/api_client.dart';
import '../data/services/secure_storage_service.dart';
import '../models/dashboard_stats.dart';

class DashboardService {
  final ApiClient apiClient;

  DashboardService({ApiClient? client})
      : apiClient = client ?? ApiClient(storageService: SecureStorageService());

  Future<DashboardSummary> getSummary() async {
    try {
      final summaryRes = await apiClient.get('/dashboard/summary');
      final kpiRes = await apiClient.get('/dashboard/kpi');
      final summaryData = summaryRes.data as Map<String, dynamic>? ?? {};
      final kpiData = kpiRes.data as Map<String, dynamic>? ?? {};

      final merged = <String, dynamic>{
        ...summaryData,
        ...kpiData,
      };

      double avgKpi = 88.5;
      try {
        final employeesRes = await apiClient.get('/employees');
        final employees = employeesRes.data as List<dynamic>? ?? [];
        if (employees.isNotEmpty) {
          double sum = 0.0;
          for (var emp in employees) {
            sum += ((emp['kpi'] ?? 0.0) as num).toDouble();
          }
          avgKpi = sum / employees.length;
        }
      } catch (_) {}

      int alertCount = 0;
      try {
        final notificationsRes = await apiClient.get('/notifications');
        final notifications = notificationsRes.data as List<dynamic>? ?? [];
        alertCount = notifications.where((item) => item['is_read'] != true).length;
      } catch (_) {}

      return DashboardSummary.fromJson(merged, avgKpi: avgKpi, alertCount: alertCount);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChartDataPoint>> getRevenueChart() async {
    try {
      final response = await apiClient.get('/dashboard/revenue-chart');
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        final dateStr = map['date']?.toString() ?? '';
        String label = dateStr;
        if (dateStr.length >= 10) {
          final parts = dateStr.split('-');
          if (parts.length == 3) {
            label = '${parts[2]}/${parts[1]}';
          }
        }
        return ChartDataPoint(
          label: label,
          value: double.tryParse(map['revenue']?.toString() ?? '') ?? 0.0,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ChartDataPoint>> getOrdersChart() async {
    try {
      final response = await apiClient.get('/dashboard/orders-chart');
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        final dateStr = map['date']?.toString() ?? '';
        String label = dateStr;
        if (dateStr.length >= 10) {
          final parts = dateStr.split('-');
          if (parts.length == 3) {
            label = '${parts[2]}/${parts[1]}';
          }
        }
        return ChartDataPoint(
          label: label,
          value: double.tryParse(map['order_count']?.toString() ?? '') ?? 0.0,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<EmployeeRank>> getTopEmployees() async {
    try {
      final response = await apiClient.get('/employees');
      final list = response.data as List<dynamic>? ?? [];
      final employees = list.map((item) => item as Map<String, dynamic>).toList();

      employees.sort((a, b) {
        final double kpiA = ((a['kpi'] ?? 0.0) as num).toDouble();
        final double kpiB = ((b['kpi'] ?? 0.0) as num).toDouble();
        return kpiB.compareTo(kpiA);
      });

      final top5 = employees.take(5).toList();

      return top5.map((item) => EmployeeRank.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<DashboardAlert>> getAlerts() async {
    try {
      final response = await apiClient.get('/notifications');
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => DashboardAlert.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> markAlertAsRead(String id) async {
    try {
      await apiClient.post('/notifications/$id/read');
    } catch (e) {
      rethrow;
    }
  }
}
