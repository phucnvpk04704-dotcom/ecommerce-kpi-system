import '../../core/network/api_client.dart';

abstract class RevenueRepository {
  Future<List<Map<String, dynamic>>> getRevenues({int skip = 0, int limit = 100});
  Future<Map<String, dynamic>> getEmployeeRevenueStats(
    String employeeId, {
    required String platform,
    required String startDate,
    required String endDate,
  });
}

class RevenueRepositoryImpl implements RevenueRepository {
  final ApiClient apiClient;

  RevenueRepositoryImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getRevenues({int skip = 0, int limit = 100}) async {
    try {
      final response = await apiClient.get(
        '/revenues',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getEmployeeRevenueStats(
    String employeeId, {
    required String platform,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await apiClient.get(
        '/revenues/stats/employee/$employeeId',
        queryParameters: {
          'platform': platform,
          'start_date': startDate,
          'end_date': endDate,
        },
      );
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      rethrow;
    }
  }
}
