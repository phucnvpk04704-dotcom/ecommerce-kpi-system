import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/custom_provider.dart';
import '../providers/report_provider.dart';
import '../services/report_service.dart';
import '../widgets/report_summary_card.dart';
import '../widgets/report_chart.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/top_employee_tile.dart';
import '../widgets/top_product_tile.dart';

class ReportScreen extends StatefulWidget {
  final ReportService? service;

  const ReportScreen({
    super.key,
    this.service,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider<ReportProvider>(
      create: (_) => ReportProvider(service: widget.service)
        ..loadReports()
        ..loadSummary()
        ..loadRevenue()
        ..loadOrders()
        ..loadProducts()
        ..loadEmployees(),
      child: Consumer<ReportProvider>(
        builder: (context, provider, child) {
          final list = provider.reports;

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF120005) : const Color(0xFFFDF7F8),
            appBar: AppBar(
              title: const Text('Reports & Analytics'),
              backgroundColor: isDark ? const Color(0xFF1D0308) : const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: RefreshIndicator(
              onRefresh: () => provider.refresh(),
              color: const Color(0xFFFF5722),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Filters inputs
                    ReportFilterBar(
                      selectedPlatform: provider.platform,
                      selectedPeriod: provider.period,
                      onPlatformChanged: (pf) => provider.filter(platform: pf),
                      onPeriodChanged: (p) => provider.filter(period: p),
                    ),
                    const SizedBox(height: 16),

                    // Body scroll
                    Expanded(
                      child: _buildBodyContent(context, provider, list),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, ReportProvider provider, List<dynamic> list) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              'Error loading analytics data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722), foregroundColor: Colors.white),
              onPressed: () => provider.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final sum = provider.summary;
    final totalRevenue = (sum['total_revenue'] ?? 0.0) as num;
    final totalOrders = (sum['total_orders'] ?? 0) as int;
    final completedOrders = (sum['completed_orders'] ?? 0) as int;
    final cancelledOrders = (sum['cancelled_orders'] ?? 0) as int;
    final averageOrderValue = (sum['average_order_value'] ?? 0.0) as num;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;

        final leftWidgets = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportSummaryCard(
              totalRevenue: totalRevenue.toDouble(),
              totalOrders: totalOrders,
              completedOrders: completedOrders,
              cancelledOrders: cancelledOrders,
              averageOrderValue: averageOrderValue.toDouble(),
            ),
            const SizedBox(height: 16),
            ReportChart(
              data: provider.revenueData,
              xKey: 'date',
              yKey: 'revenue',
              type: 'revenue',
            ),
            const SizedBox(height: 16),
            ReportChart(
              data: provider.ordersData,
              xKey: 'date',
              yKey: 'orders',
              type: 'orders',
            ),
          ],
        );

        final rightWidgets = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Performing Employees
            _buildSectionHeader(context, 'Top Performers', Icons.stars_rounded),
            const SizedBox(height: 8),
            provider.employeeData.isEmpty
                ? const Text('No employee rankings logs', style: TextStyle(color: Colors.grey, fontSize: 12))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.employeeData.length,
                    itemBuilder: (context, index) {
                      final item = provider.employeeData[index];
                      return TopEmployeeTile(
                        index: index,
                        name: item['employee_name']?.toString() ?? '',
                        department: item['department']?.toString() ?? '',
                        kpiScore: double.tryParse(item['kpi_score']?.toString() ?? '0.0') ?? 0.0,
                        revenue: double.tryParse(item['revenue']?.toString() ?? '0.0') ?? 0.0,
                      );
                    },
                  ),
            const SizedBox(height: 24),

            // Top Products Sold
            _buildSectionHeader(context, 'Best Selling Products', Icons.shopping_basket_rounded),
            const SizedBox(height: 8),
            provider.productData.isEmpty
                ? const Text('No product lists logged', style: TextStyle(color: Colors.grey, fontSize: 12))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.productData.length,
                    itemBuilder: (context, index) {
                      final item = provider.productData[index];
                      return TopProductTile(
                        index: index,
                        productName: item['product_name']?.toString() ?? '',
                        quantity: int.tryParse(item['quantity']?.toString() ?? '0') ?? 0,
                        revenue: double.tryParse(item['revenue']?.toString() ?? '0.0') ?? 0.0,
                      );
                    },
                  ),
            const SizedBox(height: 24),

            // Reports Archive List
            _buildSectionHeader(context, 'Generated Reports Archive', Icons.library_books_rounded),
            const SizedBox(height: 8),
            list.isEmpty
                ? const Text('No reports compiled', style: TextStyle(color: Colors.grey, fontSize: 12))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          onTap: () {
                            context.go('/report_detail_screen/${item.id}');
                          },
                          leading: const Icon(Icons.assignment_outlined, color: Color(0xFFFF5722)),
                          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('Type: ${item.reportType} | Period: ${item.period}', style: const TextStyle(fontSize: 11)),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                        ),
                      );
                    },
                  ),
          ],
        );

        if (isTablet) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: leftWidgets),
                const SizedBox(width: 16),
                Expanded(flex: 5, child: rightWidgets),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                leftWidgets,
                const SizedBox(height: 24),
                rightWidgets,
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF5722), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2B0008),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
