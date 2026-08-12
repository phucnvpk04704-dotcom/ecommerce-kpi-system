import 'package:flutter/material.dart';

class KpiTrend extends StatelessWidget {
  const KpiTrend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trendData = [
      {'period': 'Q1 2026', 'average': 82.4, 'change': '+1.2%'},
      {'period': 'Q2 2026', 'average': 85.1, 'change': '+2.7%'},
      {'period': 'Q3 2026', 'average': 88.5, 'change': '+3.4%'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KPI Quarterly Trend',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Column(
              children: trendData.map((item) {
                final double score = item['average'] as double;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          item['period'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: score / 100,
                            minHeight: 10,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${score.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item['change'] as String,
                        style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
