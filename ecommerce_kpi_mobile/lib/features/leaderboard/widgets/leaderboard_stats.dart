import 'package:flutter/material.dart';

class LeaderboardStats extends StatelessWidget {
  final double topScore;
  final int totalContenders;
  final double averageScore;

  const LeaderboardStats({
    super.key,
    required this.topScore,
    required this.totalContenders,
    required this.averageScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return GridView.count(
      crossAxisCount: isDesktop ? 3 : (width >= 600 ? 3 : 1),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isDesktop ? 2.0 : 2.4,
      children: [
        _buildStatCard(
          context,
          title: 'Top KPI Score',
          value: '${topScore.toStringAsFixed(1)}%',
          icon: Icons.star_border,
          color: const Color(0xFFFFD700), // Gold
        ),
        _buildStatCard(
          context,
          title: 'Average Group Score',
          value: '${averageScore.toStringAsFixed(1)}%',
          icon: Icons.group_outlined,
          color: theme.colorScheme.secondary,
        ),
        _buildStatCard(
          context,
          title: 'Active Contenders',
          value: '$totalContenders profiles',
          icon: Icons.military_tech_outlined,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
