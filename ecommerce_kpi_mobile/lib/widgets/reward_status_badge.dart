import 'package:flutter/material.dart';

class RewardStatusBadge extends StatelessWidget {
  final String status;

  const RewardStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final cleanStatus = status.trim().toLowerCase();
    Color badgeColor;
    String text;

    if (cleanStatus == 'approved') {
      badgeColor = const Color(0xFF4CAF50); // Green
      text = 'Approved';
    } else if (cleanStatus == 'rejected') {
      badgeColor = const Color(0xFFF44336); // Red
      text = 'Rejected';
    } else {
      badgeColor = const Color(0xFFFF9800); // Orange
      text = 'Pending';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(isDark ? 51 : 26),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: badgeColor.withAlpha(isDark ? 102 : 51),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
