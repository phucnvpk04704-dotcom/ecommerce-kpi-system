import '../core/network/api_client.dart';
import '../data/services/secure_storage_service.dart';
import '../models/kpi.dart';

class KpiService {
  final ApiClient apiClient;

  KpiService({ApiClient? client})
      : apiClient = client ?? ApiClient(storageService: SecureStorageService());

  Future<List<Kpi>> getTodayKpi() async {
    try {
      final response = await apiClient.get('/kpi/today');
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => Kpi.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Kpi>> getWeekKpi() async {
    try {
      final response = await apiClient.get('/kpi/week');
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => Kpi.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Kpi>> getMonthKpi() async {
    try {
      final response = await apiClient.get('/kpi/month');
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => Kpi.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Kpi> getEmployeeKpi(String employeeId) async {
    try {
      final response = await apiClient.get('/kpi/$employeeId');
      return Kpi.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Kpi>> getKpiRanking() async {
    try {
      final response = await apiClient.get('/kpi/ranking');
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => Kpi.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
