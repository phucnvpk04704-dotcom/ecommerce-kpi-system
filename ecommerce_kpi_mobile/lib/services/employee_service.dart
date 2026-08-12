import '../core/network/api_client.dart';
import '../data/services/secure_storage_service.dart';
import '../models/employee.dart';

class EmployeeService {
  final ApiClient apiClient;

  EmployeeService({ApiClient? client})
      : apiClient = client ?? ApiClient(storageService: SecureStorageService());

  Future<List<Employee>> getEmployees() async {
    try {
      final response = await apiClient.get('/employees');
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => Employee.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Employee> getEmployeeById(String id) async {
    try {
      final response = await apiClient.get('/employees/$id');
      return Employee.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Employee> createEmployee(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post('/employees', data: data);
      return Employee.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Employee> updateEmployee(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put('/employees/$id', data: data);
      return Employee.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      await apiClient.delete('/employees/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<Employee> changeStatus(String id, String status) async {
    try {
      // API PATCH /employees/{id}/status using underling dio instance
      final response = await apiClient.dio.patch(
        '/employees/$id/status',
        queryParameters: {'status': status},
      );
      return Employee.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // Fallback
      try {
        final response = await apiClient.put('/employees/$id', data: {'status': status});
        return Employee.fromJson(response.data as Map<String, dynamic>);
      } catch (_) {
        rethrow;
      }
    }
  }
}
