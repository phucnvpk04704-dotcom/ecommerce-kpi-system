import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/providers.dart';
import '../shared/responsive_layout.dart';
import 'widgets/reward_card.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rewardsAsync = ref.watch(rewardsListProvider);
    final employeesAsync = ref.watch(employeesKPIProvider);
    final theme = Theme.of(context);

    return ResponsiveLayout(
      title: 'Company Rewards',
      child: Column(
        children: [
          // Tab bar selection header
          Container(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF1D0308)
                : Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF8C7174)
                  : const Color(0xFFBCA2A5),
              indicatorColor: theme.colorScheme.primary,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Rules'),
                Tab(text: 'History'),
                Tab(text: 'Top Rewarded'),
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Overview
                _buildOverviewTab(rewardsAsync, theme),
                // Tab 2: Rules
                _buildRulesTab(theme),
                // Tab 3: History
                _buildHistoryTab(rewardsAsync, theme),
                // Tab 4: Top Rewarded
                _buildTopRewardedTab(employeesAsync, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(AsyncValue<List<Map<String, dynamic>>> rewardsAsync, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(rewardsListProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet simulator card
            _buildWalletCard(theme),
            const SizedBox(height: 24),

            // Statistics mini grid
            rewardsAsync.when(
              loading: () => const SizedBox(),
              error: (err, stack) => const SizedBox(),
              data: (rewards) {
                final total = rewards.length;
                final claimed = rewards.where((r) => r['status'] == 'Claimed').length;
                final active = rewards.where((r) => r['status'] == 'Active').length;

                return Row(
                  children: [
                    _buildSummaryMiniCard(theme, 'Total Rewards', '$total'),
                    const SizedBox(width: 12),
                    _buildSummaryMiniCard(theme, 'Claimed', '$claimed'),
                    const SizedBox(width: 12),
                    _buildSummaryMiniCard(theme, 'Active', '$active'),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(theme, 'Available Incentives'),
            const SizedBox(height: 12),

            // Available rewards list
            rewardsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading rewards: $err')),
              data: (rewards) {
                final activeList = rewards.where((r) => r['status'] == 'Active').toList();
                if (activeList.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: Text('No active incentive schemes currently.')),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeList.length,
                  itemBuilder: (context, idx) {
                    return RewardCard(reward: activeList[idx]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(ThemeData theme) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: theme.brightness == Brightness.dark
                ? [const Color(0xFF2C0A10), const Color(0xFF190205)]
                : [const Color(0xFFFFF2F4), Colors.white],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REWARD POINTS BALANCE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: theme.brightness == Brightness.dark ? const Color(0xFFE28B8B) : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '8,450 pts',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Level 4 Manager',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '1,550 pts to next tier',
                          style: TextStyle(fontSize: 11, color: Color(0xFF8C7174)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wallet_giftcard_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMiniCard(ThemeData theme, String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.brightness == Brightness.dark ? const Color(0xFF8C7174) : const Color(0xFF6E5256),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRulesTab(ThemeData theme) {
    final rules = [
      {
        'title': 'Excellent KPI Milestone',
        'metric': 'KPI Score >= 95.0',
        'reward': '1,500,000 VND / Month',
        'description': 'Awarded to employees maintaining outstanding performance over the month.',
        'icon': Icons.workspace_premium_rounded,
        'color': Colors.amber,
      },
      {
        'title': 'High Performer Benchmark',
        'metric': 'KPI Score >= 90.0',
        'reward': '800,000 VND / Month',
        'description': 'Awarded to employees exceeding standard business targets.',
        'icon': Icons.grade_rounded,
        'color': Colors.blue,
      },
      {
        'title': 'Order Master Incentive',
        'metric': 'Total Orders >= 500 / Month',
        'reward': '1,000,000 VND / Month',
        'description': 'Awarded to top employees by order count throughput.',
        'icon': Icons.shopping_bag_rounded,
        'color': Colors.green,
      },
      {
        'title': 'Flawless Operation Bonus',
        'metric': 'Penalty Points = 0',
        'reward': '300,000 VND / Month',
        'description': 'Encourages quality and policy adherence with zero disciplinary deductions.',
        'icon': Icons.verified_rounded,
        'color': Colors.teal,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: rules.length,
      itemBuilder: (context, index) {
        final rule = rules[index];
        final ruleColor = rule['color'] as Color;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ruleColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(rule['icon'] as IconData, color: ruleColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          rule['metric'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rule['description'] as String,
                        style: const TextStyle(fontSize: 12, color: Color(0xFFCCA5AB)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Corporate Bonus',
                            style: TextStyle(fontSize: 11, color: Color(0xFF8C7174)),
                          ),
                          Text(
                            rule['reward'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(AsyncValue<List<Map<String, dynamic>>> rewardsAsync, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(rewardsListProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: rewardsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (rewards) {
            final history = rewards.where((r) => r['status'] == 'Claimed').toList();

            if (history.isEmpty) {
              // Simulated history list fallback as specified in user guidelines
              final simulated = [
                {
                  'title': 'May KPI Bonus',
                  'description': 'Exceeded target monthly KPI average',
                  'reward': '1,200,000 VND',
                  'status': 'Claimed',
                  'date': '2026-05-31'
                },
                {
                  'title': 'Q1 Top Operator Award',
                  'description': 'Highest throughput in marketing order pipeline',
                  'reward': '3,500,000 VND',
                  'status': 'Claimed',
                  'date': '2026-03-31'
                },
                {
                  'title': 'April Attendance Incentive',
                  'description': 'Perfect attendance and zero policy deductions',
                  'reward': '500,000 VND',
                  'status': 'Claimed',
                  'date': '2026-04-30'
                },
              ];

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: simulated.length,
                itemBuilder: (context, index) {
                  return RewardCard(reward: simulated[index]);
                },
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              itemBuilder: (context, index) {
                return RewardCard(reward: history[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopRewardedTab(AsyncValue<List<Map<String, dynamic>>> employeesAsync, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(employeesKPIProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: employeesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (employees) {
            final sorted = List<Map<String, dynamic>>.from(employees)
              ..sort((a, b) => ((b['sales'] ?? 0.0) as num).compareTo((a['sales'] ?? 0.0) as num));

            if (sorted.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('No employees found.')),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(theme, 'Highest Bonus Achievers'),
                const SizedBox(height: 14),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sorted.length.clamp(0, 5),
                  itemBuilder: (context, index) {
                    final emp = sorted[index];
                    final mockRewardAmount = (1200000 - (index * 200000)).clamp(300000, 2000000);
                    final String name = emp['name'] ?? 'Employee';
                    final String dept = emp['department'] ?? 'Marketing';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          '$dept | KPI: ${emp['kpi']}%',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Text(
                          '+$mockRewardAmount VND',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 16,
        letterSpacing: -0.2,
      ),
    );
  }
}
