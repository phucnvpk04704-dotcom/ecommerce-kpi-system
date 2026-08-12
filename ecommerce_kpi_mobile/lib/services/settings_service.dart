import '../core/network/api_client.dart';
import '../data/services/secure_storage_service.dart';
import '../models/settings.dart';

class SettingsService {
  final ApiClient apiClient;

  SettingsService({ApiClient? client})
      : apiClient = client ?? ApiClient(storageService: SecureStorageService());

  Future<ManagerSettings> getProfile() async {
    try {
      final response = await apiClient.get('/settings/profile');
      return ManagerSettings.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return const ManagerSettings(
        managerName: 'Operations Manager',
        email: 'manager@shopee-kpi.com',
        phone: '0987654321',
        avatar: '',
        language: 'English',
        themeMode: 'System',
        notificationEnabled: true,
        biometricEnabled: false,
        appVersion: '1.0.0',
      );
    }
  }

  Future<ManagerSettings> updateProfile(ManagerSettings settings) async {
    try {
      final response = await apiClient.put(
        '/settings/profile',
        data: {
          'manager_name': settings.managerName,
          'email': settings.email,
          'phone': settings.phone,
          'avatar': settings.avatar,
        },
      );
      return ManagerSettings.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return settings;
    }
  }

  Future<Map<String, dynamic>> updatePreferences(ManagerSettings settings) async {
    try {
      final response = await apiClient.put(
        '/settings/preferences',
        data: {
          'language': settings.language,
          'theme_mode': settings.themeMode,
          'notification_enabled': settings.notificationEnabled,
          'biometric_enabled': settings.biometricEnabled,
        },
      );
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      return {
        'language': settings.language,
        'theme_mode': settings.themeMode,
        'notification_enabled': settings.notificationEnabled,
        'biometric_enabled': settings.biometricEnabled,
      };
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await apiClient.post(
        '/auth/change-password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
