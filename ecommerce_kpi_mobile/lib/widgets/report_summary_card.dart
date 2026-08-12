import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportSummaryCard extends StatelessWidget {
  final double totalRevenue;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double averageOrderValue;

  const ReportSummaryCard({
    super.key,
    required this.totalRevenue,
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.averageOrderValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D0308) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(51) : const Color(0xFF800020).withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Financial Performance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2B0008),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.monetization_on_rounded, color: const Color(0xFFFF5722), size: 20),
            ],
          ),
          const SizedBox(height: 16),

          // Revenue large amount
          Text(
            currencyFormat.format(totalRevenue),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2B0008),
            ),
          ),
          const Text('Total Accumulated Revenue', style: TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 16),

          const Divider(height: 1),
          const SizedBox(height: 16),

          // Mini statistics metrics grid
          Row(
            children: [
              _buildStatItem(context, 'Total Orders', '$totalOrders', Icons.shopping_bag_rounded),
              _buildStatItem(context, 'Avg. Ticket (AOV)', currencyFormat.format(averageOrderValue), Icons.analytics_rounded),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(context, 'Completed Orders', '$completedOrders', Icons.check_circle_rounded, color: Colors.green),
              _buildStatItem(context, 'Cancelled Orders', '$cancelledOrders', Icons.cancel_rounded, color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, {Color? color}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? const Color(0xFFFF5722)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2B0008),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
