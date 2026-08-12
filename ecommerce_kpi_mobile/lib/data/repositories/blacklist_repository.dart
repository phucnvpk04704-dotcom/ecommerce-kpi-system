import '../../core/network/api_client.dart';

abstract class BlacklistRepository {
  Future<List<Map<String, dynamic>>> getBlacklist({int skip = 0, int limit = 100});
  Future<Map<String, dynamic>> addBlacklistEntry(Map<String, dynamic> blacklistData);
  Future<Map<String, dynamic>> findByPhone(String phone);
  Future<Map<String, dynamic>> removeBlacklistEntry(String id);
}

class BlacklistRepositoryImpl implements BlacklistRepository {
  final ApiClient apiClient;

  BlacklistRepositoryImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getBlacklist({int skip = 0, int limit = 100}) async {
    try {
      final response = await apiClient.get(
        '/customer_blacklist',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> addBlacklistEntry(Map<String, dynamic> blacklistData) async {
    try {
      final response = await apiClient.post(
        '/customer_blacklist',
        data: blacklistData,
      );
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> findByPhone(String phone) async {
    try {
      final response = await apiClient.get(
        '/customer_blacklist/phone/$phone',
      );
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> removeBlacklistEntry(String id) async {
    try {
      final response = await apiClient.delete(
        '/customer_blacklist/$id',
      );
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      rethrow;
    }
  }
}
