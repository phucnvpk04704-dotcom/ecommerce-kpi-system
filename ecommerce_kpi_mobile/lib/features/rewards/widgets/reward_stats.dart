import 'package:flutter/material.dart';

class RewardStats extends StatelessWidget {
  final int totalCount;
  final int claimedCount;
  final int activeCount;

  const RewardStats({
    super.key,
    required this.totalCount,
    required this.claimedCount,
    required this.activeCount,
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
          title: 'Total Programs',
          value: totalCount.toString(),
          icon: Icons.emoji_events_outlined,
          color: theme.colorScheme.primary,
        ),
        _buildStatCard(
          context,
          title: 'Claimed Rewards',
          value: claimedCount.toString(),
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        _buildStatCard(
          context,
          title: 'Active Schemes',
          value: activeCount.toString(),
          icon: Icons.card_giftcard,
          color: theme.colorScheme.secondary,
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
