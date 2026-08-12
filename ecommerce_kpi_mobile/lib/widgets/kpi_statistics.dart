import 'package:flutter/material.dart';
import '../models/kpi.dart';

class KpiStatistics extends StatelessWidget {
  final Kpi kpi;

  const KpiStatistics({
    super.key,
    required this.kpi,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Operational Indicators',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2B0008),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _buildMetricCard(
              context,
              'Completed Orders',
              '${kpi.completedOrders}',
              Icons.done_all_rounded,
              const Color(0xFF4CAF50),
            ),
            _buildMetricCard(
              context,
              'Late Orders',
              '${kpi.lateOrders}',
              Icons.hourglass_bottom_rounded,
              const Color(0xFFF44336),
            ),
            _buildMetricCard(
              context,
              'Cancelled Orders',
              '${kpi.cancelledOrders}',
              Icons.cancel_outlined,
              Colors.grey,
            ),
            _buildMetricCard(
              context,
              'Chat Response',
              '${kpi.responseRate.toStringAsFixed(0)}%',
              Icons.chat_bubble_outline_rounded,
              Colors.blue,
            ),
            _buildMetricCard(
              context,
              'Response Time',
              '${kpi.responseTime.toStringAsFixed(1)}m',
              Icons.timer_outlined,
              Colors.teal,
            ),
            _buildMetricCard(
              context,
              'Products Created',
              '${kpi.newProducts}',
              Icons.add_box_outlined,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color iconColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D0308) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(26) : const Color(0xFF800020).withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF2B0008),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
