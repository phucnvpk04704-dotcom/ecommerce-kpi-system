import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/kpi.dart';

class KpiCard extends StatelessWidget {
  final Kpi kpi;

  const KpiCard({
    super.key,
    required this.kpi,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D0308) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(51) : const Color(0xFF800020).withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.go('/kpi_detail_screen/${kpi.employeeId}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Rank Circle
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _getRankBgColor(kpi.rank),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#${kpi.rank}',
                      style: TextStyle(
                        color: _getRankTextColor(kpi.rank),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kpi.employeeName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF2B0008),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5722).withAlpha(15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              kpi.department,
                              style: const TextStyle(
                                color: Color(0xFFFF5722),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currencyFormat.format(kpi.todayRevenue),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // KPI Score Circular indicators or simple percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getKpiColor(kpi.totalKpi).withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _getKpiColor(kpi.totalKpi).withAlpha(102),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${kpi.totalKpi.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getKpiColor(kpi.totalKpi),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRankBgColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return Colors.grey.withAlpha(26);
  }

  Color _getRankTextColor(int rank) {
    if (rank == 1 || rank == 2 || rank == 3) return const Color(0xFF2B0008);
    return Colors.grey;
  }

  Color _getKpiColor(double score) {
    if (score >= 90) return const Color(0xFF4CAF50); // Green
    if (score >= 80) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }
}
