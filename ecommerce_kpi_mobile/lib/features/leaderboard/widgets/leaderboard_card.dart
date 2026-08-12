import 'package:flutter/material.dart';

class LeaderboardCard extends StatelessWidget {
  final Map<String, dynamic> rankEntry;

  const LeaderboardCard({
    super.key,
    required this.rankEntry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int rank = rankEntry['rank'] ?? 1;
    final double score = (rankEntry['kpi'] as num?)?.toDouble() ?? 0.0;
    final String initial = (rankEntry['name'] as String).isNotEmpty
        ? (rankEntry['name'] as String).substring(0, 1).toUpperCase()
        : 'E';

    Color rankColor = theme.colorScheme.primary;
    Widget rankBadge = CircleAvatar(
      backgroundColor: theme.brightness == Brightness.dark 
          ? const Color(0xFF2C0A10) 
          : const Color(0xFFFFF2F4),
      foregroundColor: theme.colorScheme.primary,
      radius: 15,
      child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
    );

    if (rank == 1) {
      rankColor = Colors.amber;
      rankBadge = CircleAvatar(
        backgroundColor: rankColor.withValues(alpha: 0.15),
        foregroundColor: rankColor,
        radius: 15,
        child: const Icon(Icons.workspace_premium_rounded, size: 18),
      );
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
      rankBadge = CircleAvatar(
        backgroundColor: rankColor.withValues(alpha: 0.15),
        foregroundColor: rankColor,
        radius: 15,
        child: const Icon(Icons.workspace_premium_rounded, size: 18),
      );
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      rankBadge = CircleAvatar(
        backgroundColor: rankColor.withValues(alpha: 0.15),
        foregroundColor: rankColor,
        radius: 15,
        child: const Icon(Icons.workspace_premium_rounded, size: 18),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            rankBadge,
            const SizedBox(width: 14),
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                initial,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rankEntry['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${rankEntry['department']} | Rank $rank',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.brightness == Brightness.dark ? const Color(0xFFCCA5AB) : const Color(0xFF6E5256),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${score.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
