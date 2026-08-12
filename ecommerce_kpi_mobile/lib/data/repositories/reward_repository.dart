import '../../core/network/api_client.dart';

abstract class RewardRepository {
  Future<List<Map<String, dynamic>>> getRewards({int skip = 0, int limit = 100});
  Future<List<Map<String, dynamic>>> getEmployeeRewardHistory(
    String employeeId, {
    required String startDate,
    required String endDate,
  });
}

class RewardRepositoryImpl implements RewardRepository {
  final ApiClient apiClient;

  RewardRepositoryImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getRewards({int skip = 0, int limit = 100}) async {
    try {
      final response = await apiClient.get(
        '/rewards',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getEmployeeRewardHistory(
    String employeeId, {
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await apiClient.get(
        '/rewards/history/employee/$employeeId',
        queryParameters: {
          'start_date': startDate,
          'end_date': endDate,
        },
      );
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      rethrow;
    }
  }
}
