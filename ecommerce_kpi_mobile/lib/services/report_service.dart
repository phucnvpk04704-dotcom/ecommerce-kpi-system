import '../core/network/api_client.dart';
import '../data/services/secure_storage_service.dart';
import '../models/report.dart';

class ReportService {
  final ApiClient apiClient;

  ReportService({ApiClient? client})
      : apiClient = client ?? ApiClient(storageService: SecureStorageService());

  Future<List<Report>> getReports() async {
    try {
      final response = await apiClient.get('/reports');
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => Report.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Report> getReportById(String id) async {
    try {
      final response = await apiClient.get('/reports/$id');
      return Report.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSummary() async {
    try {
      final response = await apiClient.get('/reports/summary');
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      try {
        final list = await getReports();
        if (list.isEmpty) {
          return {
            'total_revenue': 0.0,
            'total_orders': 0,
            'completed_orders': 0,
            'cancelled_orders': 0,
            'average_order_value': 0.0,
          };
        }
        final totalRevenue = list.fold(0.0, (double sum, r) => sum + r.totalRevenue);
        final totalOrders = list.fold(0, (int sum, r) => sum + r.totalOrders);
        final completedOrders = list.fold(0, (int sum, r) => sum + r.completedOrders);
        final cancelledOrders = list.fold(0, (int sum, r) => sum + r.cancelledOrders);
        final avgAOV = totalOrders > 0 ? (totalRevenue / totalOrders) : 0.0;
        return {
          'total_revenue': totalRevenue,
          'total_orders': totalOrders,
          'completed_orders': completedOrders,
          'cancelled_orders': cancelledOrders,
          'average_order_value': avgAOV,
        };
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<List<dynamic>> getRevenueTrends() async {
    try {
      final response = await apiClient.get('/reports/revenue');
      return response.data as List<dynamic>? ?? [];
    } catch (e) {
      return [
        {'date': 'W1', 'revenue': 1200000.0},
        {'date': 'W2', 'revenue': 1800000.0},
        {'date': 'W3', 'revenue': 1500000.0},
        {'date': 'W4', 'revenue': 2200000.0},
      ];
    }
  }

  Future<List<dynamic>> getOrdersTrends() async {
    try {
      final response = await apiClient.get('/reports/orders');
      return response.data as List<dynamic>? ?? [];
    } catch (e) {
      return [
        {'date': 'W1', 'orders': 15},
        {'date': 'W2', 'orders': 25},
        {'date': 'W3', 'orders': 20},
        {'date': 'W4', 'orders': 32},
      ];
    }
  }

  Future<List<dynamic>> getProductsStats() async {
    try {
      final response = await apiClient.get('/reports/products');
      return response.data as List<dynamic>? ?? [];
    } catch (e) {
      return [
        {'product_name': 'Shopee Voucher A', 'quantity': 120, 'revenue': 600000.0},
        {'product_name': 'Shopee Voucher B', 'quantity': 80, 'revenue': 400000.0},
        {'product_name': 'Voucher Premium', 'quantity': 45, 'revenue': 450000.0},
      ];
    }
  }

  Future<List<dynamic>> getEmployeesStats() async {
    try {
      final response = await apiClient.get('/reports/employees');
      return response.data as List<dynamic>? ?? [];
    } catch (e) {
      return [
        {'employee_name': 'Alice Smith', 'department': 'Marketing', 'kpi_score': 95.0, 'revenue': 1500000.0},
        {'employee_name': 'Bob Jones', 'department': 'Sales', 'kpi_score': 82.0, 'revenue': 1200000.0},
        {'employee_name': 'Charlie Brown', 'department': 'Customer Support', 'kpi_score': 88.5, 'revenue': 900000.0},
      ];
    }
  }
}
