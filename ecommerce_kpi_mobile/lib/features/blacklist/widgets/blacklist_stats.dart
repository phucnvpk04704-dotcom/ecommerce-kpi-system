import 'package:flutter/material.dart';

class BlacklistStats extends StatelessWidget {
  final int totalBlacklisted;
  final int highRiskCount;
  final double averageCancellationRate;
  final int paymentFraudCount;

  const BlacklistStats({
    super.key,
    required this.totalBlacklisted,
    required this.highRiskCount,
    required this.averageCancellationRate,
    required this.paymentFraudCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return GridView.count(
      crossAxisCount: isDesktop ? 4 : (width >= 600 ? 2 : 1),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isDesktop ? 1.8 : 2.2,
      children: [
        _buildStatCard(
          context,
          title: 'Total Flagged',
          value: totalBlacklisted.toString(),
          icon: Icons.block,
          color: theme.colorScheme.primary,
        ),
        _buildStatCard(
          context,
          title: 'High Risk Profile',
          value: highRiskCount.toString(),
          icon: Icons.gpp_maybe,
          color: const Color(0xFFEF4444),
        ),
        _buildStatCard(
          context,
          title: 'Avg Order Cancel Rate',
          value: '${averageCancellationRate.toStringAsFixed(1)}%',
          icon: Icons.cancel_presentation_outlined,
          color: theme.colorScheme.secondary,
        ),
        _buildStatCard(
          context,
          title: 'Fraud Alert Count',
          value: paymentFraudCount.toString(),
          icon: Icons.security,
          color: const Color(0xFF8B5CF6),
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
