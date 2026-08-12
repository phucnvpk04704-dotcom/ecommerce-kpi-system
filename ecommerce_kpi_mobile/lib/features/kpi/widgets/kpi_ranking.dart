import 'package:flutter/material.dart';

class KpiRanking extends StatelessWidget {
  final List<Map<String, dynamic>> rankings;

  const KpiRanking({
    super.key,
    required this.rankings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topThree = rankings.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KPI Leader Rankings',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Column(
              children: List.generate(topThree.length, (index) {
                final emp = topThree[index];
                final double score = emp['kpi'] ?? 0.0;
                final rank = index + 1;

                Color rankColor = theme.colorScheme.primary;
                if (rank == 1) rankColor = const Color(0xFFFFD700); // Gold
                if (rank == 2) rankColor = const Color(0xFFC0C0C0); // Silver
                if (rank == 3) rankColor = const Color(0xFFCD7F32); // Bronze

                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: rankColor,
                    foregroundColor: rank == 1 || rank == 2 ? Colors.black : Colors.white,
                    radius: 14,
                    child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  title: Text(
                    emp['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(emp['department'] ?? ''),
                  trailing: Text(
                    '${score.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
