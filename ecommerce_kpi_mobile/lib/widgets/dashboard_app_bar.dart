import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String companyName;
  final int unreadNotifications;
  final VoidCallback onNotificationTap;
  final VoidCallback onAvatarTap;
  final String managerInitials;

  const DashboardAppBar({
    super.key,
    required this.companyName,
    required this.unreadNotifications,
    required this.onNotificationTap,
    required this.onAvatarTap,
    this.managerInitials = 'MG',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentDateStr = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());

    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1D0308) : const Color(0xFFFF5722),
      foregroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            companyName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            currentDateStr,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withAlpha(204),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, size: 26, color: Colors.white),
              onPressed: onNotificationTap,
            ),
            if (unreadNotifications > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1D0308) : const Color(0xFFFF5722),
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadNotifications > 9 ? '9+' : '$unreadNotifications',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onAvatarTap,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withAlpha(51),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Text(
                managerInitials,
                style: const TextStyle(
                  color: Color(0xFFFF5722),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
