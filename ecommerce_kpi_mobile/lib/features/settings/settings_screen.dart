import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/providers.dart';
import '../shared/responsive_layout.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _pushNotificationsEnabled = true;
  bool _biometricEnabled = false;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    } catch (_) {
      // Ignore loading error
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String initial = _user != null && (_user!['full_name'] ?? _user!['name'] ?? '').toString().isNotEmpty
        ? (_user!['full_name'] ?? _user!['name']).toString().substring(0, 1).toUpperCase()
        : 'M';

    return ResponsiveLayout(
      title: 'User Profile',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar and personal info header
            if (_user != null) ...[
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _user!['full_name'] ?? _user!['name'] ?? 'Manager',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _user!['role'] ?? 'Operations Manager',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.brightness == Brightness.dark ? const Color(0xFFCCA5AB) : const Color(0xFF6E5256),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dept: ${_user!['department'] ?? 'Operations'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            _buildSectionTitle(theme, 'Corporate Info'),
            const SizedBox(height: 12),

            // Profile info key-value list card
            if (_user != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildInfoTile(theme, 'Username', _user!['username'] ?? 'admin'),
                      _buildDivider(theme),
                      _buildInfoTile(theme, 'Email Address', _user!['email'] ?? 'admin@ecommercekpi.com'),
                      _buildDivider(theme),
                      _buildInfoTile(theme, 'Employee Code', _user!['employee_code'] ?? 'NV001'),
                      _buildDivider(theme),
                      _buildInfoTile(theme, 'Security Clearance', 'Level 4 Manager'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 28),

            _buildSectionTitle(theme, 'Preferences & Settings'),
            const SizedBox(height: 12),

            // Configuration list card
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      theme,
                      icon: Icons.notifications_active_outlined,
                      title: 'Push Notifications',
                      value: _pushNotificationsEnabled,
                      onChanged: (val) {
                        setState(() {
                          _pushNotificationsEnabled = val;
                        });
                      },
                    ),
                    _buildDivider(theme),
                    _buildSwitchTile(
                      theme,
                      icon: Icons.fingerprint_rounded,
                      title: 'Biometric Unlock',
                      value: _biometricEnabled,
                      onChanged: (val) {
                        setState(() {
                          _biometricEnabled = val;
                        });
                      },
                    ),
                    _buildDivider(theme),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.lock_reset_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text(
                        'Change Password',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF8C7174)),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Security settings are managed by corporate directory.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8C7174),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      value: value,
      activeThumbColor: theme.colorScheme.primary,
      onChanged: onChanged,
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      color: theme.brightness == Brightness.dark ? const Color(0xFF2C0A10) : const Color(0xFFF3E6E8),
      height: 1,
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 15,
        letterSpacing: -0.2,
      ),
    );
  }
}
