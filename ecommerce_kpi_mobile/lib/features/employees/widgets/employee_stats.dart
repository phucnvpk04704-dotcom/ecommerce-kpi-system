import 'package:flutter/material.dart';

class EmployeeStats extends StatelessWidget {
  final int totalEmployees;
  final double averageKpi;
  final int activeCount;
  final double totalSales;

  const EmployeeStats({
    super.key,
    required this.totalEmployees,
    required this.averageKpi,
    required this.activeCount,
    required this.totalSales,
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
      childAspectRatio: isDesktop ? 1.8 : (width >= 600 ? 3.2 : 2.5),
      children: [
        _buildStatCard(
          context,
          title: 'Total Employees',
          value: totalEmployees.toString(),
          icon: Icons.people_outline,
          color: theme.colorScheme.primary,
        ),
        _buildStatCard(
          context,
          title: 'Average KPI Score',
          value: '${averageKpi.toStringAsFixed(1)}%',
          icon: Icons.speed,
          color: theme.colorScheme.secondary,
        ),
        _buildStatCard(
          context,
          title: 'Active Ratio',
          value: '$activeCount / $totalEmployees',
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        _buildStatCard(
          context,
          title: 'Sales Generated',
          value: '\$${totalSales.toStringAsFixed(0)}',
          icon: Icons.monetization_on_outlined,
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
