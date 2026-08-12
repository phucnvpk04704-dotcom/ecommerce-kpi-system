import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../providers/custom_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/dashboard_service.dart';
import '../../models/dashboard_stats.dart';
import '../../widgets/dashboard_app_bar.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/dashboard_charts_widget.dart';
import '../../widgets/employee_ranking_list.dart';
import '../../widgets/latest_alerts_list.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../data/services/secure_storage_service.dart';

class DashboardScreen extends StatefulWidget {
  final DashboardService? dashboardService;

  const DashboardScreen({super.key, this.dashboardService});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTab = 0;
  String _managerInitials = 'MG';
  String _managerName = 'Manager';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final storage = SecureStorageService();
      final userJson = await storage.readUser();
      if (userJson != null) {
        final Map<String, dynamic> user = json.decode(userJson);
        final name = user['name'] ?? user['full_name'] ?? 'Manager';
        setState(() {
          _managerName = name;
          if (name.isNotEmpty) {
            final parts = name.trim().split(' ');
            if (parts.length >= 2) {
              _managerInitials = '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
            } else {
              _managerInitials = name.substring(0, math.min(2, name.length)).toUpperCase();
            }
          }
        });
      }
    } catch (_) {}
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentTab = index;
    });
    // Optional routing trigger or overlay display for non-dashboard pages
    if (index != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigation to tab index $index is not fully implemented in MVP.'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider<DashboardProvider>(
      create: (_) => DashboardProvider(service: widget.dashboardService)..loadDashboardData(),
      child: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          final summary = provider.summary;
          final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0);

          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeIn,
            builder: (context, opacity, child) {
              return Opacity(
                opacity: opacity,
                child: child,
              );
            },
            child: Scaffold(
              backgroundColor: isDark ? const Color(0xFF120005) : const Color(0xFFFDF7F8),
              appBar: DashboardAppBar(
                companyName: 'Ecommerce KPI',
                unreadNotifications: summary.currentAlerts,
                managerInitials: _managerInitials,
                onNotificationTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications tapped.')),
                  );
                },
                onAvatarTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logged in as $_managerName')),
                  );
                },
              ),
              body: RefreshIndicator(
                onRefresh: () => provider.loadDashboardData(silent: true),
                color: const Color(0xFFFF5722),
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final isTablet = constraints.maxWidth >= 600;
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Greeting header
                                _buildGreetingSection(theme, isDark),
                                const SizedBox(height: 20),

                                // Statistics cards grid
                                _buildStatsGrid(summary, currencyFormat, isTablet),
                                const SizedBox(height: 24),

                                // Charts Section
                                _buildChartsSection(provider, isTablet),
                                const SizedBox(height: 24),

                                // Bottom Split: Ranking & Alerts
                                _buildSplitSection(provider, isTablet),
                                const SizedBox(height: 16),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              bottomNavigationBar: DashboardBottomNavBar(
                currentIndex: _currentTab,
                onTap: _onBottomNavTap,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreetingSection(ThemeData theme, bool isDark) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 18) {
      greeting = 'Good Afternoon';
    } else if (hour >= 18) {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$greeting, ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? const Color(0xFFCCA5AB) : const Color(0xFF6E5256),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.waving_hand_rounded, color: Colors.amber, size: 16),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _managerName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 26,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : const Color(0xFF2B0008),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(DashboardSummary summary, NumberFormat currencyFormat, bool isTablet) {
    final cards = [
      StatCard(
        title: "Today's Revenue",
        value: currencyFormat.format(summary.todayRevenue),
        icon: Icons.monetization_on_rounded,
        iconColor: const Color(0xFF4CAF50),
        animationIndex: 0,
      ),
      StatCard(
        title: "Monthly Revenue",
        value: currencyFormat.format(summary.monthlyRevenue),
        icon: Icons.account_balance_wallet_rounded,
        iconColor: const Color(0xFF2196F3),
        animationIndex: 1,
      ),
      StatCard(
        title: "Today's Orders",
        value: '${summary.todayOrders}',
        icon: Icons.shopping_bag_rounded,
        iconColor: const Color(0xFFFF9800),
        animationIndex: 2,
      ),
      StatCard(
        title: "Average KPI",
        value: '${summary.averageKpi.toStringAsFixed(1)}%',
        icon: Icons.star_rounded,
        iconColor: Colors.amber,
        animationIndex: 3,
      ),
      StatCard(
        title: "Active Employees",
        value: '${summary.activeEmployees}',
        icon: Icons.people_alt_rounded,
        iconColor: Colors.teal,
        animationIndex: 4,
      ),
      StatCard(
        title: "Current Alerts",
        value: '${summary.currentAlerts}',
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.red,
        animationIndex: 5,
      ),
    ];

    if (isTablet) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
        ),
        itemCount: cards.length,
        itemBuilder: (context, idx) => cards[idx],
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.45,
        ),
        itemCount: cards.length,
        itemBuilder: (context, idx) => cards[idx],
      );
    }
  }

  Widget _buildChartsSection(DashboardProvider provider, bool isTablet) {
    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Revenue7DaysChart(data: provider.revenue7Days),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Orders7DaysChart(data: provider.orders7Days),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: KpiDistributionChart(data: provider.kpiDistribution),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Revenue7DaysChart(data: provider.revenue7Days),
          const SizedBox(height: 16),
          Orders7DaysChart(data: provider.orders7Days),
          const SizedBox(height: 16),
          KpiDistributionChart(data: provider.kpiDistribution),
        ],
      );
    }
  }

  Widget _buildSplitSection(DashboardProvider provider, bool isTablet) {
    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: EmployeeRankingList(ranks: provider.topEmployees),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: LatestAlertsList(
              criticalAlerts: provider.criticalAlerts,
              warningAlerts: provider.warningAlerts,
              resolvedAlerts: provider.resolvedAlerts,
              onMarkAsRead: provider.markAlertAsRead,
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          EmployeeRankingList(ranks: provider.topEmployees),
          const SizedBox(height: 16),
          LatestAlertsList(
            criticalAlerts: provider.criticalAlerts,
            warningAlerts: provider.warningAlerts,
            resolvedAlerts: provider.resolvedAlerts,
            onMarkAsRead: provider.markAlertAsRead,
          ),
        ],
      );
    }
  }
}
