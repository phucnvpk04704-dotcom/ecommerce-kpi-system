import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/custom_provider.dart';
import '../providers/settings_provider.dart';
import '../services/settings_service.dart';
import '../models/settings.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService? service;

  const SettingsScreen({
    super.key,
    this.service,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _initializeControllers(ManagerSettings settings) {
    if (_nameController.text.isEmpty && settings.managerName.isNotEmpty) {
      _nameController.text = settings.managerName;
    }
    if (_emailController.text.isEmpty && settings.email.isNotEmpty) {
      _emailController.text = settings.email;
    }
    if (_phoneController.text.isEmpty && settings.phone.isNotEmpty) {
      _phoneController.text = settings.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider<SettingsProvider>(
      create: (_) => SettingsProvider(service: widget.service)..loadProfile(),
      child: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          final settings = provider.profile;

          if (provider.loading && settings == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Color(0xFFFF5722))),
            );
          }

          if (settings != null) {
            _initializeControllers(settings);
          }

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF120005) : const Color(0xFFFDF7F8),
            appBar: AppBar(
              title: const Text('Settings'),
              backgroundColor: isDark ? const Color(0xFF1D0308) : const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: settings == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        const Text('Failed to load settings profile'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadProfile(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header
                          _buildProfileCard(context, settings),
                          const SizedBox(height: 24),

                          // Personal Info Fields
                          _buildSectionTitle(context, 'Personal Information'),
                          const SizedBox(height: 12),
                          _buildTextField(context, 'Full Name', _nameController, Icons.person_rounded),
                          const SizedBox(height: 12),
                          _buildTextField(context, 'Corporate Email', _emailController, Icons.email_rounded, validator: (v) {
                            if (v == null || v.isEmpty) return 'Email is required';
                            if (!v.contains('@')) return 'Invalid email format';
                            return null;
                          }),
                          const SizedBox(height: 12),
                          _buildTextField(context, 'Phone Number', _phoneController, Icons.phone_rounded),
                          const SizedBox(height: 16),

                          // Save personal info button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5722),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ?? false) {
                                  final success = await provider.updateProfile(
                                    settings.copyWith(
                                      managerName: _nameController.text,
                                      email: _emailController.text,
                                      phone: _phoneController.text,
                                    ),
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(success ? 'Profile updated successfully' : 'Failed to update profile'),
                                        backgroundColor: success ? Colors.green : Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: provider.loading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Save Personal Information', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Preferences & switches
                          _buildSectionTitle(context, 'App Preferences'),
                          const SizedBox(height: 12),

                          _buildPreferenceCard(
                            context,
                            [
                              // Dark theme switch
                              _buildSwitchTile(
                                context,
                                'Dark Mode Theme',
                                'Enable application high contrast mode',
                                Icons.dark_mode_rounded,
                                settings.themeMode == 'Dark',
                                (val) {
                                  provider.updatePreferences(
                                    settings.copyWith(themeMode: val ? 'Dark' : 'Light'),
                                  );
                                },
                              ),
                              const Divider(height: 1),

                              // Notification switch
                              _buildSwitchTile(
                                context,
                                'Push Notifications',
                                'View active general updates & KPI alerts',
                                Icons.notifications_active_rounded,
                                settings.notificationEnabled,
                                (val) {
                                  provider.updatePreferences(
                                    settings.copyWith(notificationEnabled: val),
                                  );
                                },
                              ),
                              const Divider(height: 1),

                              // Biometrics switch
                              _buildSwitchTile(
                                context,
                                'Biometric Login',
                                'Secure account using face recognition',
                                Icons.fingerprint_rounded,
                                settings.biometricEnabled,
                                (val) {
                                  provider.updatePreferences(
                                    settings.copyWith(biometricEnabled: val),
                                  );
                                },
                              ),
                              const Divider(height: 1),

                              // Language option
                              ListTile(
                                leading: const Icon(Icons.translate_rounded, color: Color(0xFFFF5722)),
                                title: const Text('Application Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text(settings.language, style: const TextStyle(fontSize: 11)),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                                onTap: () => _showLanguageDialog(context, provider, settings),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Security controls
                          _buildSectionTitle(context, 'Security & Account'),
                          const SizedBox(height: 12),

                          _buildPreferenceCard(
                            context,
                            [
                              ListTile(
                                leading: const Icon(Icons.lock_rounded, color: Colors.blue),
                                title: const Text('Change Account Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: const Text('Refresh credential codes', style: TextStyle(fontSize: 11)),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                                onTap: () => _showPasswordDialog(context, provider),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                                title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
                                subtitle: const Text('Exit secure session container', style: TextStyle(fontSize: 11)),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.red),
                                onTap: () {
                                  context.go('/login');
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // App version
                          Center(
                            child: Text(
                              'App Version: ${settings.appVersion}',
                              style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, ManagerSettings settings) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final initial = settings.managerName.isNotEmpty ? settings.managerName.substring(0, 1).toUpperCase() : 'M';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D0308) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFFFF5722).withAlpha(30),
            child: Text(
              initial,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF5722)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.managerName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2B0008),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  settings.email,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (settings.phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    settings.phone,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF2B0008),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon, {
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF5722), size: 18),
        filled: true,
        fillColor: isDark ? const Color(0xFF1D0308) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF330C14).withAlpha(100) : const Color(0xFFF3E6E8)),
        ),
      ),
    );
  }

  Widget _buildPreferenceCard(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF1D0308) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
          ),
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFF5722)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFFFF5722),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider provider, ManagerSettings settings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['English', 'Vietnamese', 'Spanish', 'Japanese'].map((lang) {
              return ListTile(
                title: Text(lang),
                trailing: settings.language == lang ? const Icon(Icons.check, color: Color(0xFFFF5722)) : null,
                onTap: () {
                  provider.updatePreferences(settings.copyWith(language: lang));
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showPasswordDialog(BuildContext context, SettingsProvider provider) {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Old Password'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm Password'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_newPasswordController.text != _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
                  );
                  return;
                }
                final success = await provider.changePassword(
                  _oldPasswordController.text,
                  _newPasswordController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Password changed successfully' : 'Failed to change password'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Submit', style: TextStyle(color: Color(0xFFFF5722))),
            ),
          ],
        );
      },
    );
  }
}
