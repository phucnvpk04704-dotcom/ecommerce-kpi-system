import '../core/network/api_client.dart';
import '../data/services/secure_storage_service.dart';
import '../models/blacklist_customer.dart';

class BlacklistService {
  final ApiClient apiClient;

  BlacklistService({ApiClient? client})
      : apiClient = client ?? ApiClient(storageService: SecureStorageService());

  Future<List<BlacklistCustomer>> getBlacklist() async {
    try {
      final response = await apiClient.get('/blacklist');
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => BlacklistCustomer.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<BlacklistCustomer> getCustomerById(String id) async {
    try {
      final response = await apiClient.get('/blacklist/$id');
      return BlacklistCustomer.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await apiClient.get('/blacklist/statistics');
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      try {
        final list = await getBlacklist();
        final total = list.length;
        final high = list.where((c) => c.riskLevel.toLowerCase() == 'high').length;
        final warning = list.where((c) => c.riskLevel.toLowerCase() == 'warning').length;
        return {
          'total_blacklist': total,
          'high_risk_count': high,
          'warning_risk_count': warning,
        };
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<BlacklistCustomer> createCustomer(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post('/blacklist', data: data);
      return BlacklistCustomer.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<BlacklistCustomer> updateCustomer(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put('/blacklist/$id', data: data);
      return BlacklistCustomer.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<BlacklistCustomer> changeStatus(String id, String status) async {
    try {
      final response = await apiClient.dio.patch('/blacklist/$id/status', data: {'status': status});
      return BlacklistCustomer.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      try {
        final response = await apiClient.put('/blacklist/$id', data: {'status': status});
        return BlacklistCustomer.fromJson(response.data as Map<String, dynamic>);
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await apiClient.delete('/blacklist/$id');
    } catch (e) {
      rethrow;
    }
  }
}
