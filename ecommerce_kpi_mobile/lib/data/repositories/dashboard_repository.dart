import '../../core/network/api_client.dart';

abstract class DashboardRepository {
  Future<Map<String, dynamic>> getSummary();
  Future<Map<String, dynamic>> getKpi();
  Future<List<Map<String, dynamic>>> getRevenueChart();
  Future<List<Map<String, dynamic>>> getOrdersChart();
  Future<Map<String, dynamic>> getRecentActivities();
}

class DashboardRepositoryImpl implements DashboardRepository {
  final ApiClient apiClient;

  DashboardRepositoryImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getSummary() async {
    try {
      final response = await apiClient.get('/dashboard/summary');
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getKpi() async {
    try {
      final response = await apiClient.get('/dashboard/kpi');
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRevenueChart() async {
    try {
      final response = await apiClient.get('/dashboard/revenue-chart');
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOrdersChart() async {
    try {
      final response = await apiClient.get('/dashboard/orders-chart');
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getRecentActivities() async {
    try {
      final response = await apiClient.get('/dashboard/recent-activities');
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      rethrow;
    }
  }
}
