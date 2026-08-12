import '../../core/network/api_client.dart';

abstract class EmployeeRepository {
  Future<List<Map<String, dynamic>>> getEmployees({int skip = 0, int limit = 100});
  Future<Map<String, dynamic>> createEmployee(Map<String, dynamic> employeeData);
  Future<Map<String, dynamic>> updateEmployee(String id, Map<String, dynamic> employeeData);
  Future<Map<String, dynamic>> deleteEmployee(String id);
}

class EmployeeRepositoryImpl implements EmployeeRepository {
  final ApiClient apiClient;

  EmployeeRepositoryImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getEmployees({int skip = 0, int limit = 100}) async {
    try {
      final response = await apiClient.get(
        '/employees',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createEmployee(Map<String, dynamic> employeeData) async {
    try {
      final response = await apiClient.post(
        '/employees',
        data: employeeData,
      );
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateEmployee(String id, Map<String, dynamic> employeeData) async {
    try {
      final response = await apiClient.put(
        '/employees/$id',
        data: employeeData,
      );
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> deleteEmployee(String id) async {
    try {
      final response = await apiClient.delete(
        '/employees/$id',
      );
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      rethrow;
    }
  }
}
