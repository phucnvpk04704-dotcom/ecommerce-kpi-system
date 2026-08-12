import 'package:flutter/material.dart';

class BlacklistSummaryCard extends StatelessWidget {
  final int totalCount;
  final int highRiskCount;
  final int warningCount;

  const BlacklistSummaryCard({
    super.key,
    required this.totalCount,
    required this.highRiskCount,
    required this.warningCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D0308) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(51) : const Color(0xFF800020).withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Total Blacklist Count
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.people_alt_rounded, color: Colors.grey, size: 20),
                  const SizedBox(height: 6),
                  Text(
                    '$totalCount',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2B0008),
                    ),
                  ),
                  const Text(
                    'Total Blacklist',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1, color: Colors.grey),

            // High Risk Count
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.gavel_rounded, color: Color(0xFFF44336), size: 20),
                  const SizedBox(height: 6),
                  Text(
                    '$highRiskCount',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF44336),
                    ),
                  ),
                  const Text(
                    'High Risk',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1, color: Colors.grey),

            // Warning Count
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.warning_rounded, color: Color(0xFFFF9800), size: 20),
                  const SizedBox(height: 6),
                  Text(
                    '$warningCount',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                  const Text(
                    'Warning',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
