import 'package:flutter/material.dart';

class NotificationCard extends StatefulWidget {
  final Map<String, dynamic> alert;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.alert,
    required this.onTap,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String type = widget.alert['type'] ?? 'info';
    final bool isRead = widget.alert['read'] ?? false;
    final String message = widget.alert['message'] ?? '';

    IconData alertIcon = Icons.info_outline_rounded;
    Color alertColor = theme.colorScheme.secondary;
    String priorityLabel = 'Low';
    Color priorityColor = Colors.blue;

    if (type.contains('kpi')) {
      alertIcon = Icons.warning_amber_rounded;
      alertColor = Colors.orange;
      priorityLabel = 'High';
      priorityColor = Colors.orange;
    } else if (type.contains('blacklist')) {
      alertIcon = Icons.gpp_maybe_rounded;
      alertColor = theme.colorScheme.error;
      priorityLabel = 'High';
      priorityColor = theme.colorScheme.error;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isRead 
          ? theme.cardTheme.color 
          : theme.colorScheme.primary.withValues(alpha: 0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
          if (!isRead) {
            widget.onTap();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: alertColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(alertIcon, color: alertColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.alert['title'] ?? 'System Alert',
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            if (!isRead) ...[
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Icon(
                              _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Text(
                        message,
                        maxLines: _isExpanded ? 100 : 2,
                        overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark ? const Color(0xFFCCA5AB) : const Color(0xFF6E5256),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.alert['created_at'] != null ? widget.alert['created_at'].toString().split('T')[0] : 'Today',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.brightness == Brightness.dark ? const Color(0xFF8C7174) : const Color(0xFFBCA2A5),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$priorityLabel Priority',
                            style: TextStyle(
                              color: priorityColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
