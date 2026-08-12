import 'package:flutter/material.dart';

class RevenueStats extends StatelessWidget {
  final double totalRevenue;
  final double averageMonthlyRevenue;
  final double targetRevenue;
  final double completionRate;

  const RevenueStats({
    super.key,
    required this.totalRevenue,
    required this.averageMonthlyRevenue,
    required this.targetRevenue,
    required this.completionRate,
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
          title: 'Total Year-to-Date',
          value: '\$${totalRevenue.toStringAsFixed(0)}',
          icon: Icons.monetization_on,
          color: theme.colorScheme.primary,
        ),
        _buildStatCard(
          context,
          title: 'Monthly Average',
          value: '\$${averageMonthlyRevenue.toStringAsFixed(0)}',
          icon: Icons.calendar_today_outlined,
          color: theme.colorScheme.secondary,
        ),
        _buildStatCard(
          context,
          title: 'Year Target',
          value: '\$${targetRevenue.toStringAsFixed(0)}',
          icon: Icons.flag_outlined,
          color: Colors.green,
        ),
        _buildStatCard(
          context,
          title: 'Target Achieved',
          value: '${(completionRate * 100).toStringAsFixed(1)}%',
          icon: Icons.percent,
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
