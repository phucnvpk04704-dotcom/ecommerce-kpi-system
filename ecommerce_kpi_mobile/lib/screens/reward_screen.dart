import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/custom_provider.dart';
import '../providers/reward_provider.dart';
import '../services/reward_service.dart';
import '../widgets/reward_card.dart';
import '../widgets/reward_summary_card.dart';
import '../widgets/reward_filter_bar.dart';

class RewardScreen extends StatefulWidget {
  final RewardService? service;

  const RewardScreen({
    super.key,
    this.service,
  });

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider<RewardProvider>(
      create: (_) => RewardProvider(service: widget.service)
        ..loadRewards()
        ..loadSummary(),
      child: Consumer<RewardProvider>(
        builder: (context, provider, child) {
          final list = provider.rewardList;

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF120005) : const Color(0xFFFDF7F8),
            appBar: AppBar(
              title: const Text('Reward Management'),
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
                    // Tabs switcher (Active vs History)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _showHistory = false;
                              });
                              provider.loadRewards();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: !_showHistory ? const Color(0xFFFF5722) : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Pending & Active',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !_showHistory ? const Color(0xFFFF5722) : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _showHistory = true;
                              });
                              provider.loadHistory();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _showHistory ? const Color(0xFFFF5722) : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Rewards History',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _showHistory ? const Color(0xFFFF5722) : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Filter bar
                    RewardFilterBar(
                      selectedPeriod: provider.period,
                      selectedStatus: provider.status,
                      selectedDepartment: provider.department,
                      searchKeyword: provider.searchKeyword,
                      onPeriodChanged: (p) => provider.filter(period: p),
                      onStatusChanged: (s) => provider.filter(status: s),
                      onDepartmentChanged: (dept) => provider.filter(department: dept),
                      onSearchKeywordChanged: (keyword) => provider.search(keyword),
                    ),
                    const SizedBox(height: 16),

                    // Body
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
                context.go('/reward_create_screen');
              },
              child: const Icon(Icons.add_rounded),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, RewardProvider provider, List<dynamic> list) {
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
              'Error loading rewards',
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

    final totalBudget = (provider.summary['total_reward_amount'] ?? 0.0) as num;
    final staffRewarded = (provider.summary['employees_rewarded'] ?? 0) as int;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No rewards found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'No reward history matches current search keywords or filters.',
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

        final summaryWidget = RewardSummaryCard(
          totalAmount: totalBudget.toDouble(),
          employeesCount: staffRewarded,
        );

        final listWidget = ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return RewardCard(reward: list[index]);
          },
        );

        if (isTablet) {
          // Left Summary, Right List
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: summaryWidget,
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
          // Stacked
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                summaryWidget,
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
