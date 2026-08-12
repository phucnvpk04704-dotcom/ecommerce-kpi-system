import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/custom_provider.dart';
import '../providers/kpi_provider.dart';
import '../services/kpi_service.dart';
import '../widgets/kpi_score_circle.dart';
import '../widgets/kpi_progress_card.dart';
import '../widgets/kpi_statistics.dart';

class KpiDetailScreen extends StatefulWidget {
  final String employeeId;
  final KpiService? service;

  const KpiDetailScreen({
    super.key,
    required this.employeeId,
    this.service,
  });

  @override
  State<KpiDetailScreen> createState() => _KpiDetailScreenState();
}

class _KpiDetailScreenState extends State<KpiDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0);

    return ChangeNotifierProvider<KpiProvider>(
      create: (_) => KpiProvider(service: widget.service)..loadEmployee(widget.employeeId),
      child: Consumer<KpiProvider>(
        builder: (context, provider, child) {
          final kpi = provider.selectedKpi;

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF120005) : const Color(0xFFFDF7F8),
            appBar: AppBar(
              title: const Text('KPI Performance Profile'),
              backgroundColor: isDark ? const Color(0xFF1D0308) : const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: RefreshIndicator(
              onRefresh: () => provider.refresh(),
              color: const Color(0xFFFF5722),
              child: provider.loading && kpi == null
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
                  : provider.error != null
                      ? _buildErrorContent(context, provider)
                      : kpi == null
                          ? _buildEmptyContent(context)
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final isTablet = constraints.maxWidth >= 600;

                                final scoreSection = Column(
                                  children: [
                                    KpiScoreCircle(score: kpi.totalKpi, radius: 90),
                                    const SizedBox(height: 16),
                                    Text(
                                      kpi.employeeName,
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF2B0008),
                                      ),
                                    ),
                                    Text(
                                      'Position Rank: #${kpi.rank} | ${kpi.department}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Reward estimate
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withAlpha(20),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.purple.withAlpha(51)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.card_giftcard_rounded, color: Colors.purple, size: 20),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              'Reward Estimate: ${currencyFormat.format(kpi.rewardEstimate)}',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: Colors.purple,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );

                                final progressSection = Column(
                                  children: [
                                    KpiProgressCard(
                                      title: 'Revenue Target',
                                      score: kpi.kpiRevenue,
                                      metricValue: 'Today Sales: ${currencyFormat.format(kpi.todayRevenue)}',
                                      icon: Icons.monetization_on_rounded,
                                      color: const Color(0xFF4CAF50),
                                    ),
                                    const SizedBox(height: 12),
                                    KpiProgressCard(
                                      title: 'Orders Fulfillment',
                                      score: kpi.kpiOrder,
                                      metricValue: 'Completed: ${kpi.completedOrders} | Late: ${kpi.lateOrders}',
                                      icon: Icons.shopping_bag_rounded,
                                      color: const Color(0xFFFF9800),
                                    ),
                                    const SizedBox(height: 12),
                                    KpiProgressCard(
                                      title: 'Chat Communications',
                                      score: kpi.kpiChat,
                                      metricValue: 'Response Rate: ${kpi.responseRate.toStringAsFixed(0)}% | Speed: ${kpi.responseTime.toStringAsFixed(1)}m',
                                      icon: Icons.chat_bubble_outline_rounded,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(height: 12),
                                    KpiProgressCard(
                                      title: 'Products Management',
                                      score: kpi.kpiProduct,
                                      metricValue: 'New: ${kpi.newProducts} | Updates: ${kpi.updatedProducts}',
                                      icon: Icons.add_box_outlined,
                                      color: Colors.purple,
                                    ),
                                  ],
                                );

                                final metricsGrid = KpiStatistics(kpi: kpi);

                                if (isTablet) {
                                  return SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              scoreSection,
                                              const SizedBox(height: 24),
                                              metricsGrid,
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: progressSection,
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        scoreSection,
                                        const SizedBox(height: 24),
                                        progressSection,
                                        const SizedBox(height: 24),
                                        metricsGrid,
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, KpiProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text('Error loading performance details', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(provider.error ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722), foregroundColor: Colors.white),
            onPressed: () => provider.loadEmployee(widget.employeeId),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('KPI performance profile not found'),
        ],
      ),
    );
  }
}
