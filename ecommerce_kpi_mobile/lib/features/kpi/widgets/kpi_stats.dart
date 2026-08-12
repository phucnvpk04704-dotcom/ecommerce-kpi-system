import 'package:flutter/material.dart';

class KpiStats extends StatelessWidget {
  final double averageKpi;
  final double highestKpi;
  final double lowestKpi;
  final int targetMetCount;

  const KpiStats({
    super.key,
    required this.averageKpi,
    required this.highestKpi,
    required this.lowestKpi,
    required this.targetMetCount,
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
          title: 'Average KPI Score',
          value: '${averageKpi.toStringAsFixed(1)}%',
          icon: Icons.speed,
          color: theme.colorScheme.primary,
        ),
        _buildStatCard(
          context,
          title: 'Highest Score',
          value: '${highestKpi.toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: Colors.green,
        ),
        _buildStatCard(
          context,
          title: 'Lowest Score',
          value: '${lowestKpi.toStringAsFixed(1)}%',
          icon: Icons.trending_down,
          color: Colors.red,
        ),
        _buildStatCard(
          context,
          title: 'Targets Met (>=90%)',
          value: '$targetMetCount employees',
          icon: Icons.assignment_turned_in_outlined,
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
