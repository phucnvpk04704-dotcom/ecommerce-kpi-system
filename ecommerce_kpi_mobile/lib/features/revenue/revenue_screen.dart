import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/network/providers.dart';
import '../shared/responsive_layout.dart';
import 'widgets/revenue_stats.dart';
import 'widgets/platform_breakdown.dart';
import 'widgets/revenue_target_tracker.dart';

class RevenueScreen extends ConsumerStatefulWidget {
  const RevenueScreen({super.key});

  @override
  ConsumerState<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends ConsumerState<RevenueScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final revenuesAsync = ref.watch(revenuesProvider);
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);

    return ResponsiveLayout(
      title: 'Revenue Analytics',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics summary header
            revenuesAsync.when(
              loading: () => const SizedBox(),
              error: (err, stack) => const SizedBox(),
              data: (revenueList) {
                if (revenueList.isEmpty) return const SizedBox();

                double totalRev = 0;
                double totalTgt = 0;

                for (final item in revenueList) {
                  totalRev += item['revenue'] ?? 0.0;
                  totalTgt += item['target'] ?? 0.0;
                }

                final avgRev = totalRev / revenueList.length;
                final completionRate = totalTgt > 0 ? (totalRev / totalTgt) : 0.0;

                return RevenueStats(
                  totalRevenue: totalRev,
                  averageMonthlyRevenue: avgRev,
                  targetRevenue: totalTgt,
                  completionRate: completionRate,
                );
              },
            ),
            const SizedBox(height: 24),

            // Responsive Layout split for Breakdown and Tracker
            if (isDesktop) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: PlatformBreakdown()),
                  const SizedBox(width: 16),
                  Expanded(
                    child: revenuesAsync.when(
                      loading: () => const SizedBox(),
                      error: (err, stack) => const SizedBox(),
                      data: (revenueList) {
                        double totalRev = 0;
                        double totalTgt = 0;
                        for (final item in revenueList) {
                          totalRev += item['revenue'] ?? 0.0;
                          totalTgt += item['target'] ?? 0.0;
                        }
                        return RevenueTargetTracker(
                          achieved: totalRev,
                          target: totalTgt,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              const PlatformBreakdown(),
              const SizedBox(height: 16),
              revenuesAsync.when(
                loading: () => const SizedBox(),
                error: (err, stack) => const SizedBox(),
                data: (revenueList) {
                  double totalRev = 0;
                  double totalTgt = 0;
                  for (final item in revenueList) {
                    totalRev += item['revenue'] ?? 0.0;
                    totalTgt += item['target'] ?? 0.0;
                  }
                  return RevenueTargetTracker(
                    achieved: totalRev,
                    target: totalTgt,
                  );
                },
              ),
            ],
            const SizedBox(height: 24),

            // Controls: Search & Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search month (e.g. Jan, Feb)...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedStatus,
                  underline: const SizedBox(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedStatus = val;
                      });
                    }
                  },
                  items: ['All', 'Target Met', 'Pending']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Trend list overview
            Text(
              'Monthly Accomplishments List',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            revenuesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading revenues: $err')),
              data: (revenueList) {
                final filtered = revenueList.where((item) {
                  final double revenue = item['revenue'] ?? 0.0;
                  final double target = item['target'] ?? 0.0;
                  final isSuccess = revenue >= target;

                  final matchesSearch = (item['month'] as String).toLowerCase().contains(_searchQuery);
                  final matchesStatus = _selectedStatus == 'All' ||
                      (_selectedStatus == 'Target Met' && isSuccess) ||
                      (_selectedStatus == 'Pending' && !isSuccess);

                  return matchesSearch && matchesStatus;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assessment_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No monthly records match filters.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final double revenue = item['revenue'] ?? 0.0;
                    final double target = item['target'] ?? 0.0;
                    final double completionRatio = target > 0 ? (revenue / target) : 0.0;
                    final percent = (completionRatio * 100).toStringAsFixed(1);
                    final isSuccess = completionRatio >= 1.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['month'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isSuccess ? Colors.green : theme.colorScheme.secondary).withAlpha(26),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isSuccess ? 'Target Met' : 'Pending',
                                    style: TextStyle(
                                      color: isSuccess ? Colors.green : theme.colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Achieved: ${currencyFormat.format(revenue)}'),
                                Text('Target: ${currencyFormat.format(target)}'),
                                Text('$percent%', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
