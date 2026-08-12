import '../../core/network/api_client.dart';

abstract class NotificationRepository {
  Future<List<Map<String, dynamic>>> getNotifications({int skip = 0, int limit = 100});
  Future<Map<String, dynamic>> markAsRead(String id);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient apiClient;

  NotificationRepositoryImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getNotifications({int skip = 0, int limit = 100}) async {
    try {
      final response = await apiClient.get(
        '/notifications',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> markAsRead(String id) async {
    try {
      final response = await apiClient.post(
        '/notifications/$id/read',
      );
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      rethrow;
    }
  }
}
