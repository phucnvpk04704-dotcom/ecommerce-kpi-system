class ManagerSettings {
  final String managerName;
  final String email;
  final String phone;
  final String avatar;
  final String language;
  final String themeMode; // e.g. Light, Dark, System
  final bool notificationEnabled;
  final bool biometricEnabled;
  final String appVersion;

  const ManagerSettings({
    required this.managerName,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.language,
    required this.themeMode,
    required this.notificationEnabled,
    required this.biometricEnabled,
    required this.appVersion,
  });

  factory ManagerSettings.fromJson(Map<String, dynamic> json) {
    return ManagerSettings(
      managerName: json['manager_name']?.toString() ?? json['managerName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      language: json['language']?.toString() ?? 'English',
      themeMode: json['theme_mode']?.toString() ?? json['themeMode']?.toString() ?? 'System',
      notificationEnabled: json['notification_enabled'] == true || json['notificationEnabled'] == true,
      biometricEnabled: json['biometric_enabled'] == true || json['biometricEnabled'] == true,
      appVersion: json['app_version']?.toString() ?? json['appVersion']?.toString() ?? '1.0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manager_name': managerName,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'language': language,
      'theme_mode': themeMode,
      'notification_enabled': notificationEnabled,
      'biometric_enabled': biometricEnabled,
      'app_version': appVersion,
    };
  }

  ManagerSettings copyWith({
    String? managerName,
    String? email,
    String? phone,
    String? avatar,
    String? language,
    String? themeMode,
    bool? notificationEnabled,
    bool? biometricEnabled,
    String? appVersion,
  }) {
    return ManagerSettings(
      managerName: managerName ?? this.managerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
