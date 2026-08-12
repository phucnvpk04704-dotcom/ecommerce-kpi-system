import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/providers.dart';
import '../shared/responsive_layout.dart';
import 'widgets/notification_card.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _searchQuery = '';
  String _selectedPriority = 'All';
  String _selectedRead = 'All';

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final theme = Theme.of(context);

    return ResponsiveLayout(
      title: 'Notifications Center',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search text field
            TextField(
              decoration: InputDecoration(
                hintText: 'Search alert by title...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 12),

            // Filters horizontal choices
            _buildFiltersRow(theme),
            const SizedBox(height: 16),

            // Notifications List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(notificationsProvider);
                },
                child: notificationsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error loading alerts: $err')),
                  data: (notifications) {
                    final filtered = notifications.where((alert) {
                      final type = alert['type'] ?? 'info';
                      final bool read = alert['read'] ?? false;
                      final String title = (alert['title'] ?? '').toString().toLowerCase();

                      String priority = 'Low';
                      if (type.contains('kpi') || type.contains('blacklist')) {
                        priority = 'High';
                      }

                      final matchesSearch = title.contains(_searchQuery);
                      final matchesRead = _selectedRead == 'All' ||
                          (_selectedRead == 'Read' && read) ||
                          (_selectedRead == 'Unread' && !read);
                      final matchesPrio = _selectedPriority == 'All' || priority == _selectedPriority;

                      return matchesSearch && matchesRead && matchesPrio;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none_rounded, size: 54, color: theme.brightness == Brightness.dark ? const Color(0xFF6B4B50) : Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No recent alerts match filters.',
                              style: TextStyle(
                                color: theme.brightness == Brightness.dark ? const Color(0xFFCCA5AB) : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final alert = filtered[index];
                        return NotificationCard(
                          alert: alert,
                          onTap: () async {
                            await ref.read(notificationsProvider.notifier).markAsRead(alert['id']);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Marked "${alert['title']}" as read'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersRow(ThemeData theme) {
    final List<String> priorityFilters = ['All', 'High', 'Low'];
    final List<String> readFilters = ['All', 'Unread', 'Read'];

    return Row(
      children: [
        // Read filter selection
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _selectedRead,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: 'Read Status',
              labelStyle: const TextStyle(fontSize: 12),
            ),
            items: readFilters
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status, style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedRead = val;
                });
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        // Priority filter selection
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _selectedPriority,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: 'Priority',
              labelStyle: const TextStyle(fontSize: 12),
            ),
            items: priorityFilters
                .map((prio) => DropdownMenuItem(
                      value: prio,
                      child: Text(prio, style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedPriority = val;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
