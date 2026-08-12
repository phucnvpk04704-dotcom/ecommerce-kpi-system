import 'dart:convert';
import '../../core/network/api_client.dart';
import '../services/secure_storage_service.dart';

abstract class AuthRepository {
  Future<String> login({required String username, required String password});
  Future<void> logout();
  Future<Map<String, dynamic>?> getCurrentUser();
  Future<bool> isAuthenticated();
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;
  final SecureStorageService storageService;

  AuthRepositoryImpl({
    required this.apiClient,
    required this.storageService,
  });

  @override
  Future<String> login({required String username, required String password}) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['access_token'] as String? ?? '';
      
      if (token.isNotEmpty) {
        await storageService.writeToken(token);
        final user = {
          'id': data['employee_id'] ?? '',
          'employee_code': data['employee_code'] ?? '',
          'name': data['full_name'] ?? '',
          'role': data['role'] ?? '',
        };
        await storageService.writeUser(jsonEncode(user));
      }
      return token;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Best effort request to blacklist the token, then clear local storage
      try {
        await apiClient.post('/auth/logout');
      } catch (_) {
        // Ignore error as logout is best effort
      }
    } finally {
      await storageService.deleteToken();
      await storageService.deleteUser();
    }
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userJson = await storageService.readUser();
      if (userJson != null) {
        return jsonDecode(userJson) as Map<String, dynamic>;
      }
      final response = await apiClient.get('/auth/validate');
      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final user = {
          'id': data['employee_id'] ?? '',
          'name': data['username'] ?? '',
          'role': data['role'] ?? '',
        };
        await storageService.writeUser(jsonEncode(user));
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await storageService.readToken();
    return token != null && token.isNotEmpty;
  }
}
