import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TopEmployeeTile extends StatelessWidget {
  final int index;
  final String name;
  final String department;
  final double kpiScore;
  final double revenue;

  const TopEmployeeTile({
    super.key,
    required this.index,
    required this.name,
    required this.department,
    required this.kpiScore,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0);

    // Medal indicator colors
    Color indexColor;
    if (index == 0) {
      indexColor = const Color(0xFFFFD700); // Gold
    } else if (index == 1) {
      indexColor = const Color(0xFFC0C0C0); // Silver
    } else if (index == 2) {
      indexColor = const Color(0xFFCD7F32); // Bronze
    } else {
      indexColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D0308).withAlpha(120) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF330C14).withAlpha(100) : const Color(0xFFF3E6E8),
        ),
      ),
      child: Row(
        children: [
          // Index Badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: indexColor.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: indexColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name and Department
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2B0008),
                  ),
                ),
                Text(
                  department,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // KPI Score & Revenue contribution
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'KPI: ${kpiScore.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF5722)),
              ),
              Text(
                currencyFormat.format(revenue),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
