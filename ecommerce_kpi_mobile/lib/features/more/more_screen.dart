import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/providers.dart';
import '../../core/theme/app_router.dart';
import '../shared/responsive_layout.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authRepo = ref.read(authRepositoryProvider);
    final user = await authRepo.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(notificationsProvider);

    int unreadCount = 0;
    notificationsAsync.whenData((notifications) {
      unreadCount = notifications.where((n) => !(n['read'] as bool? ?? false)).length;
    });

    final String initial = _user != null && (_user!['full_name'] ?? _user!['name'] ?? '').toString().isNotEmpty
        ? (_user!['full_name'] ?? _user!['name']).toString().substring(0, 1).toUpperCase()
        : 'M';

    return ResponsiveLayout(
      title: 'More',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manager info header card
            if (_user != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Text(
                          initial,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _user!['full_name'] ?? _user!['name'] ?? 'Manager',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_user!['role']} | Code: ${_user!['employee_code'] ?? 'NV001'}',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.brightness == Brightness.dark ? const Color(0xFFCCA5AB) : const Color(0xFF6E5256),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            _buildSectionTitle(theme, 'Manager Controls'),
            const SizedBox(height: 12),

            // Options List Card
            Card(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildListTile(
                    theme,
                    icon: Icons.person_outline_rounded,
                    iconColor: Colors.blue,
                    title: 'Profile Details',
                    subtitle: 'View corporate email, credentials & parameters',
                    onTap: () => context.go('/profile'),
                  ),
                  _buildDivider(theme),
                  _buildListTile(
                    theme,
                    icon: Icons.notifications_none_rounded,
                    iconColor: Colors.orange,
                    title: 'Notifications Center',
                    subtitle: 'View general updates & performance alerts',
                    trailingBadge: unreadCount > 0 ? '$unreadCount' : null,
                    onTap: () => context.go('/notifications'),
                  ),
                  _buildDivider(theme),
                  _buildListTile(
                    theme,
                    icon: Icons.emoji_events_outlined,
                    iconColor: Colors.amber,
                    title: 'Performance Leaderboard',
                    subtitle: 'View global ranking position lists',
                    onTap: () => context.go('/leaderboard'),
                  ),
                  _buildDivider(theme),
                  _buildListTile(
                    theme,
                    icon: Icons.gpp_maybe_outlined,
                    iconColor: theme.colorScheme.error,
                    title: 'Blacklist Risk Management',
                    subtitle: 'Monitor customer blacklist profiles',
                    onTap: () => context.go('/blacklist'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authRepositoryProvider).logout();
                  ref.read(authStateProvider.notifier).state = false;
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? trailingBadge,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: theme.brightness == Brightness.dark ? const Color(0xFF8C7174) : const Color(0xFFBCA2A5),
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingBadge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                trailingBadge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF8C7174)),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      color: theme.brightness == Brightness.dark ? const Color(0xFF2C0A10) : const Color(0xFFF3E6E8),
      height: 1,
      indent: 58,
      endIndent: 16,
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
