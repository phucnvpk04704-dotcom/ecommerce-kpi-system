import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/network/providers.dart';
import '../shared/responsive_layout.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    } catch (_) {
      // Ignore profile loading error
    }
  }

  Widget _buildAnimatedWidget(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 85)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1.0 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final kpiOverviewAsync = ref.watch(kpiOverviewProvider);
    final revenuesAsync = ref.watch(revenuesProvider);
    final employeesAsync = ref.watch(employeesKPIProvider);
    final notificationsAsync = ref.watch(notificationsProvider);

    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0);

    return ResponsiveLayout(
      title: 'Enterprise Dashboard',
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(kpiOverviewProvider);
          ref.invalidate(revenuesProvider);
          ref.invalidate(employeesKPIProvider);
          ref.invalidate(notificationsProvider);
          await _loadProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Greeting Section
              _buildAnimatedWidget(_buildGreeting(theme), 0),
              const SizedBox(height: 24),

              _buildAnimatedWidget(
                kpiOverviewAsync.when(
                  loading: () => _buildShimmerDashboard(),
                  error: (err, stack) => _buildErrorState(err.toString()),
                  data: (kpis) {
                    final double totalRev = (kpis['total_revenue'] as num?)?.toDouble() ?? 0.0;
                    final double targetRev = (kpis['revenue_target'] as num?)?.toDouble() ?? 6500000000.0;
                    final double avgKpi = (kpis['average_kpi'] as num?)?.toDouble() ?? 0.0;
                    final int rewardsCount = kpis['rewards_distributed'] ?? 0;
                    final int blacklistCount = kpis['blacklisted_count'] ?? 0;
                    final double revenueProgress = targetRev > 0 ? (totalRev / targetRev) : 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. Today's Revenue & Progress Card
                        _buildRevenueCard(theme, totalRev, targetRev, revenueProgress, currencyFormat),
                        const SizedBox(height: 24),

                        // 3. Core KPI Quick Stats Grid
                        _buildKpiGrid(theme, avgKpi, rewardsCount, blacklistCount),
                      ],
                    );
                  },
                ),
                1,
              ),
              const SizedBox(height: 28),

              // 4. Weekly Performance Chart
              _buildAnimatedWidget(_buildWeeklyChartSection(theme, revenuesAsync, currencyFormat), 2),
              const SizedBox(height: 28),

              // 5. Revenue by Marketplace
              _buildAnimatedWidget(_buildMarketplaceSection(theme), 3),
              const SizedBox(height: 28),

              // 6. Top Employees Leaderboard Section
              _buildAnimatedWidget(_buildTopEmployeesSection(theme, employeesAsync), 4),
              const SizedBox(height: 28),

              // 7. Recent Alerts Section
              _buildAnimatedWidget(_buildAlertsSection(theme, notificationsAsync), 5),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(ThemeData theme) {
    final String greetingName = _user != null ? (_user!['full_name'] ?? _user!['name'] ?? 'Manager') : 'Manager';
    final DateTime now = DateTime.now();
    String welcomeMsg = 'Good day';
    if (now.hour < 12) {
      welcomeMsg = 'Good morning';
    } else if (now.hour < 18) {
      welcomeMsg = 'Good afternoon';
    } else {
      welcomeMsg = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$welcomeMsg,',
              style: TextStyle(
                fontSize: 16,
                color: theme.brightness == Brightness.dark ? const Color(0xFFCCA5AB) : const Color(0xFF6E5256),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.waving_hand, size: 16, color: Colors.amber),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          greetingName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 26,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueCard(
    ThemeData theme,
    double current,
    double target,
    double progress,
    NumberFormat currencyFormat,
  ) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.brightness == Brightness.dark
                ? [const Color(0xFF2C0A10), const Color(0xFF190205)]
                : [const Color(0xFFFFF2F4), Colors.white],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL SALES REVENUE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: theme.brightness == Brightness.dark ? const Color(0xFFE28B8B) : theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currencyFormat.format(current),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: theme.colorScheme.primary,
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Progress',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.brightness == Brightness.dark ? const Color(0xFFCCA5AB) : const Color(0xFF6E5256),
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Target: ${currencyFormat.format(target)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.brightness == Brightness.dark ? const Color(0xFF8C7174) : const Color(0xFFBCA2A5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiGrid(ThemeData theme, double avgKpi, int rewards, int blacklist) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.95,
      children: [
        _buildStatCard(
          theme,
          title: 'Store KPI',
          value: '${avgKpi.toStringAsFixed(1)}%',
          icon: Icons.speed_rounded,
          color: theme.colorScheme.primary,
        ),
        _buildStatCard(
          theme,
          title: 'Rewards',
          value: rewards.toString(),
          icon: Icons.emoji_events_rounded,
          color: Colors.amber,
        ),
        _buildStatCard(
          theme,
          title: 'Risks',
          value: blacklist.toString(),
          icon: Icons.gpp_maybe_rounded,
          color: theme.colorScheme.error,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: theme.brightness == Brightness.dark ? const Color(0xFF8C7174) : const Color(0xFF6E5256),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChartSection(ThemeData theme, AsyncValue<List<Map<String, dynamic>>> revenuesAsync, NumberFormat currencyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'Monthly Revenue Trend'),
        const SizedBox(height: 14),
        revenuesAsync.when(
          loading: () => _buildShimmerChart(),
          error: (err, stack) => Center(child: Text('Error loading chart: $err')),
          data: (revenueList) {
            if (revenueList.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('No historical revenue data.')),
                ),
              );
            }

            double maxVal = 0;
            for (final item in revenueList) {
              final double val = (item['revenue'] as num?)?.toDouble() ?? 0.0;
              if (val > maxVal) maxVal = val;
            }
            if (maxVal == 0) maxVal = 1.0;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: revenueList.map((item) {
                        final double rev = (item['revenue'] as num?)?.toDouble() ?? 0.0;
                        final double heightFactor = rev / maxVal;
                        final String month = item['month'] ?? '';

                        return Column(
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: heightFactor.clamp(0.05, 1.0)),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutCubic,
                              builder: (context, animValue, child) {
                                return Container(
                                  height: 130 * animValue,
                                  width: 16,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        theme.colorScheme.primaryContainer,
                                        theme.colorScheme.primary,
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                        blurRadius: 6,
                                        offset: const Offset(0, -2),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              month,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMarketplaceSection(ThemeData theme) {
    final platforms = [
      {'name': 'Shopee', 'percent': 0.45, 'value': '2,925M', 'color': const Color(0xFFEE4D2D)},
      {'name': 'Lazada', 'percent': 0.28, 'value': '1,820M', 'color': const Color(0xFF0F146D)},
      {'name': 'TikTok Shop', 'percent': 0.18, 'value': '1,170M', 'color': const Color(0xFF000000)},
      {'name': 'Website', 'percent': 0.09, 'value': '585M', 'color': theme.colorScheme.primary},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'Sales by Marketplace'),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: platforms.map((plat) {
                final double percent = plat['percent'] as double;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: plat['color'] as Color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                plat['name'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                plat['value'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${(percent * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.brightness == Brightness.dark ? const Color(0xFF8C7174) : const Color(0xFFBCA2A5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 6,
                          backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF2C0A10) : const Color(0xFFFAF0F1),
                          valueColor: AlwaysStoppedAnimation<Color>(plat['color'] as Color),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopEmployeesSection(ThemeData theme, AsyncValue<List<Map<String, dynamic>>> employeesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'Top Performance Leaders'),
        const SizedBox(height: 14),
        employeesAsync.when(
          loading: () => _buildShimmerList(3),
          error: (err, stack) => Center(child: Text('Error loading employees: $err')),
          data: (employees) {
            // Sort by KPI descending
            final sorted = List<Map<String, dynamic>>.from(employees)
              ..sort((a, b) => ((b['kpi'] ?? 0.0) as num).compareTo((a['kpi'] ?? 0.0) as num));
            final topThree = sorted.take(3).toList();

            return Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Column(
                  children: topThree.map((emp) {
                    final int idx = topThree.indexOf(emp) + 1;
                    final double kpi = (emp['kpi'] as num?)?.toDouble() ?? 0.0;
                    final String name = emp['name'] ?? 'Employee';
                    final String dept = emp['department'] ?? 'Operations';

                    Color rankColor = const Color(0xFF8C7174);
                    if (idx == 1) rankColor = Colors.amber;
                    if (idx == 2) rankColor = const Color(0xFFC0C0C0);
                    if (idx == 3) rankColor = const Color(0xFFCD7F32);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: rankColor,
                            child: Text(
                              '$idx',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  dept,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.brightness == Brightness.dark ? const Color(0xFF8C7174) : const Color(0xFFBCA2A5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${kpi.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAlertsSection(ThemeData theme, AsyncValue<List<Map<String, dynamic>>> notificationsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'Recent Alerts & Activity'),
        const SizedBox(height: 14),
        notificationsAsync.when(
          loading: () => _buildShimmerList(2),
          error: (err, stack) => Center(child: Text('Error loading alerts: $err')),
          data: (notifs) {
            final activeNotifs = notifs.take(3).toList();
            if (activeNotifs.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text('No active alert notifications.')),
                ),
              );
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Column(
                  children: activeNotifs.map((notif) {
                    final String msg = notif['message'] ?? '';
                    final String title = notif['title'] ?? 'Alert';
                    final String type = notif['type'] ?? 'info';
                    final bool isRead = notif['read'] as bool? ?? false;

                    IconData alertIcon = Icons.info_outline;
                    Color iconColor = Colors.blue;
                    if (type.contains('kpi')) {
                      alertIcon = Icons.warning_amber_rounded;
                      iconColor = Colors.orange;
                    } else if (type.contains('blacklist')) {
                      alertIcon = Icons.gpp_maybe_rounded;
                      iconColor = Colors.red;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(alertIcon, color: iconColor, size: 22),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isRead ? Colors.grey : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  msg,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.brightness == Brightness.dark ? const Color(0xFF8C7174) : const Color(0xFFBCA2A5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 17,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildShimmerDashboard() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildShimmerChart() {
    return const SizedBox(
      height: 100,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildShimmerList(int count) {
    return const SizedBox(
      height: 80,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Text('Error: $error'),
    );
  }
}
