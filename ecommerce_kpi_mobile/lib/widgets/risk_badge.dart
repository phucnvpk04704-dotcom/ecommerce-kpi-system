import 'package:flutter/material.dart';

class RiskBadge extends StatelessWidget {
  final String riskLevel;

  const RiskBadge({
    super.key,
    required this.riskLevel,
  });

  @override
  Widget build(BuildContext context) {
    final cleanLevel = riskLevel.trim().toLowerCase();
    Color badgeColor;
    String text;

    if (cleanLevel == 'high') {
      badgeColor = const Color(0xFFF44336); // Red
      text = 'High Risk';
    } else if (cleanLevel == 'warning') {
      badgeColor = const Color(0xFFFF9800); // Orange
      text = 'Warning';
    } else {
      badgeColor = const Color(0xFF4CAF50); // Green
      text = 'Safe';
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
      child: Text(
        text,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
