import 'package:flutter/material.dart';
import '../models/settings.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service;

  SettingsProvider({SettingsService? service})
      : _service = service ?? SettingsService();

  bool _loading = false;
  bool get loading => _loading;

  ManagerSettings? _profile;
  ManagerSettings? get profile => _profile;

  Map<String, dynamic> _preferences = {
    'language': 'English',
    'theme_mode': 'System',
    'notification_enabled': true,
    'biometric_enabled': false,
  };
  Map<String, dynamic> get preferences => _preferences;

  String? _error;
  String? get error => _error;

  Future<void> loadProfile() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _service.getProfile();
      _preferences = {
        'language': _profile?.language ?? 'English',
        'theme_mode': _profile?.themeMode ?? 'System',
        'notification_enabled': _profile?.notificationEnabled ?? true,
        'biometric_enabled': _profile?.biometricEnabled ?? false,
      };
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(ManagerSettings settings) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _service.updateProfile(settings);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePreferences(ManagerSettings settings) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _service.updatePreferences(settings);
      _profile = settings;
      _preferences = {
        'language': res['language']?.toString() ?? settings.language,
        'theme_mode': res['theme_mode']?.toString() ?? settings.themeMode,
        'notification_enabled': res['notification_enabled'] == true,
        'biometric_enabled': res['biometric_enabled'] == true,
      };
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.changePassword(oldPassword, newPassword);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
