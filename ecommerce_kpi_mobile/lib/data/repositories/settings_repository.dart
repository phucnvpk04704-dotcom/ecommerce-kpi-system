import '../../core/network/api_client.dart';

abstract class SettingsRepository {
  Future<List<Map<String, dynamic>>> getSettings({int skip = 0, int limit = 100});
  Future<Map<String, dynamic>> getSettingByKey(String key);
  Future<Map<String, dynamic>> updateSetting(String settingId, Map<String, dynamic> settingData);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final ApiClient apiClient;

  SettingsRepositoryImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getSettings({int skip = 0, int limit = 100}) async {
    try {
      final response = await apiClient.get(
        '/settings',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getSettingByKey(String key) async {
    try {
      final response = await apiClient.get(
        '/settings/key/$key',
      );
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateSetting(String settingId, Map<String, dynamic> settingData) async {
    try {
      final response = await apiClient.put(
        '/settings/$settingId',
        data: settingData,
      );
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      rethrow;
    }
  }
}
