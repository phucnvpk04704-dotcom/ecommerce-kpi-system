import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';

class LatestAlertsList extends StatelessWidget {
  final List<DashboardAlert> criticalAlerts;
  final List<DashboardAlert> warningAlerts;
  final List<DashboardAlert> resolvedAlerts;
  final Function(String) onMarkAsRead;

  const LatestAlertsList({
    super.key,
    required this.criticalAlerts,
    required this.warningAlerts,
    required this.resolvedAlerts,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D0308) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
        ),
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest Alerts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF2B0008),
              ),
            ),
            const SizedBox(height: 12),
            TabBar(
              labelColor: const Color(0xFFFF5722),
              unselectedLabelColor: isDark ? const Color(0xFFCCA5AB) : const Color(0xFF8C7174),
              indicatorColor: const Color(0xFFFF5722),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelPadding: EdgeInsets.zero,
              tabs: [
                Tab(
                  child: Text(
                    'Critical (${criticalAlerts.length})',
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tab(
                  child: Text(
                    'Warning (${warningAlerts.length})',
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tab(
                  child: Text(
                    'Resolved (${resolvedAlerts.length})',
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                children: [
                  _buildAlertList(context, criticalAlerts, AlertSeverity.critical),
                  _buildAlertList(context, warningAlerts, AlertSeverity.warning),
                  _buildAlertList(context, resolvedAlerts, AlertSeverity.resolved),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertList(BuildContext context, List<DashboardAlert> list, AlertSeverity severity) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (list.isEmpty) {
      return Center(
        child: Text(
          'No alerts in this category',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? const Color(0xFFCCA5AB).withAlpha(153) : const Color(0xFF8C7174).withAlpha(179),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final alert = list[index];
        final iconData = _getSeverityIcon(severity);
        final severityColor = _getSeverityColor(severity);

        return InkWell(
          onTap: () {
            if (!alert.isRead) {
              onMarkAsRead(alert.id);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: alert.isRead
                  ? Colors.transparent
                  : (isDark ? const Color(0xFF26050C) : const Color(0xFFFFECEE)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  iconData,
                  color: severityColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF2B0008),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            alert.time,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: isDark ? const Color(0xFFCCA5AB).withAlpha(179) : const Color(0xFF8C7174),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? const Color(0xFFCCA5AB).withAlpha(230) : const Color(0xFF6E5256),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Icons.error_outline_rounded;
      case AlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case AlertSeverity.resolved:
        return Icons.check_circle_outline_rounded;
    }
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.resolved:
        return Colors.green;
    }
  }
}
