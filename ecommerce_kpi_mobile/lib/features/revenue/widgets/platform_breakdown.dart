import 'package:flutter/material.dart';

class PlatformBreakdown extends StatelessWidget {
  const PlatformBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final platforms = [
      {'name': 'Web Store', 'share': 0.45, 'sales': 639225.0},
      {'name': 'Mobile App', 'share': 0.35, 'sales': 497175.0},
      {'name': 'Social Commerce', 'share': 0.20, 'sales': 284100.0},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Channel Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: platforms.map((plat) {
                final double share = plat['share'] as double;
                final double sales = plat['sales'] as double;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            plat['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            '\$${sales.toStringAsFixed(0)} (${(share * 100).toStringAsFixed(0)}%)',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: share,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        ),
                      ),
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
