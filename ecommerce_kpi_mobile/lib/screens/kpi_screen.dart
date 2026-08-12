import 'package:flutter/material.dart';
import '../providers/custom_provider.dart';
import '../providers/kpi_provider.dart';
import '../services/kpi_service.dart';
import '../widgets/kpi_card.dart';
import '../widgets/kpi_filter_bar.dart';
import '../widgets/kpi_chart.dart';

class KpiScreen extends StatefulWidget {
  final KpiService? service;

  const KpiScreen({
    super.key,
    this.service,
  });

  @override
  State<KpiScreen> createState() => _KpiScreenState();
}

class _KpiScreenState extends State<KpiScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider<KpiProvider>(
      create: (_) => KpiProvider(service: widget.service)..loadToday(),
      child: Consumer<KpiProvider>(
        builder: (context, provider, child) {
          final kpis = provider.listKpi;

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF120005) : const Color(0xFFFDF7F8),
            appBar: AppBar(
              title: const Text('KPI Management'),
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
                    // Search & Filters panel
                    KpiFilterBar(
                      selectedPeriod: provider.selectedPeriod,
                      selectedDepartment: provider.departmentFilter,
                      searchKeyword: provider.searchKeyword,
                      onPeriodChanged: (period) {
                        if (period == 'today') provider.loadToday();
                        if (period == 'week') provider.loadWeek();
                        if (period == 'month') provider.loadMonth();
                      },
                      onDepartmentChanged: (dept) => provider.filter(dept),
                      onSearchKeywordChanged: (query) => provider.search(query),
                    ),
                    const SizedBox(height: 16),

                    // Body content
                    Expanded(
                      child: _buildBodyContent(context, provider, kpis),
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

  Widget _buildBodyContent(BuildContext context, KpiProvider provider, List<dynamic> list) {
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
              'Error loading KPI dashboard',
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

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assessment_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No KPI records found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'No statistics align with the search keywords or department filters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;

        final listWidget = ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return KpiCard(kpi: list[index]);
          },
        );

        final chartWidget = KpiChart(kpiList: provider.listKpi);

        if (isTablet) {
          // Side by Side on Tablet
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: chartWidget,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      listWidget,
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          // Vertical layout on Phone
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                chartWidget,
                const SizedBox(height: 16),
                listWidget,
              ],
            ),
          );
        }
      },
    );
  }
}
