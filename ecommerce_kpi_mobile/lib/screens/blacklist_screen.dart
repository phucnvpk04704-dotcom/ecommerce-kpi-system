import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/custom_provider.dart';
import '../providers/blacklist_provider.dart';
import '../services/blacklist_service.dart';
import '../widgets/customer_card.dart';
import '../widgets/blacklist_summary_card.dart';
import '../widgets/blacklist_filter_bar.dart';

class BlacklistScreen extends StatefulWidget {
  final BlacklistService? service;

  const BlacklistScreen({
    super.key,
    this.service,
  });

  @override
  State<BlacklistScreen> createState() => _BlacklistScreenState();
}

class _BlacklistScreenState extends State<BlacklistScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider<BlacklistProvider>(
      create: (_) => BlacklistProvider(service: widget.service)
        ..loadCustomers()
        ..loadStatistics(),
      child: Consumer<BlacklistProvider>(
        builder: (context, provider, child) {
          final list = provider.customerList;

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF120005) : const Color(0xFFFDF7F8),
            appBar: AppBar(
              title: const Text('Blacklist Management'),
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
                    // Filter inputs bar
                    BlacklistFilterBar(
                      riskLevel: provider.riskLevel,
                      platform: provider.platform,
                      status: provider.status,
                      searchKeyword: provider.searchKeyword,
                      onRiskLevelChanged: (rl) => provider.filter(riskLevel: rl),
                      onPlatformChanged: (pf) => provider.filter(platform: pf),
                      onStatusChanged: (st) => provider.filter(status: st),
                      onSearchKeywordChanged: (keyword) => provider.search(keyword),
                    ),
                    const SizedBox(height: 16),

                    // Content list view block
                    Expanded(
                      child: _buildBodyContent(context, provider, list),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              onPressed: () {
                context.go('/blacklist_create_screen');
              },
              child: const Icon(Icons.add_rounded),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, BlacklistProvider provider, List<dynamic> list) {
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
              'Error loading blacklist',
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

    final totalCount = (provider.statistics['total_blacklist'] ?? 0) as int;
    final highCount = (provider.statistics['high_risk_count'] ?? 0) as int;
    final warningCount = (provider.statistics['warning_risk_count'] ?? 0) as int;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No customers found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'No blacklist logs matches current search keyword filters.',
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

        final statsWidget = BlacklistSummaryCard(
          totalCount: totalCount,
          highRiskCount: highCount,
          warningCount: warningCount,
        );

        final listWidget = ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return CustomerCard(customer: list[index]);
          },
        );

        if (isTablet) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: statsWidget,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: listWidget,
                ),
              ),
            ],
          );
        } else {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                statsWidget,
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
