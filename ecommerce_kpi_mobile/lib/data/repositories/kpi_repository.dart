import '../../core/network/api_client.dart';

abstract class KpiRepository {
  Future<Map<String, dynamic>> getKpiSummary();
}

class KpiRepositoryImpl implements KpiRepository {
  final ApiClient apiClient;

  KpiRepositoryImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getKpiSummary() async {
    try {
      final response = await apiClient.get('/kpi/summary');
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      rethrow;
    }
  }
}
