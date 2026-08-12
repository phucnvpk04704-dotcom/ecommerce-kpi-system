import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_kpi_mobile/screens/dashboard/dashboard_screen.dart';
import 'package:ecommerce_kpi_mobile/services/dashboard_service.dart';
import 'package:ecommerce_kpi_mobile/models/dashboard_stats.dart';

class MockDashboardService extends DashboardService {
  @override
  Future<DashboardSummary> getSummary() async {
    return const DashboardSummary(
      todayRevenue: 46637076.47,
      monthlyRevenue: 6021561504.36,
      todayOrders: 36,
      averageKpi: 95.0,
      activeEmployees: 20,
      currentAlerts: 2,
    );
  }

  @override
  Future<List<ChartDataPoint>> getRevenueChart() async {
    return const [
      ChartDataPoint(label: '24/05', value: 67130176.26),
      ChartDataPoint(label: '25/05', value: 85130176.26),
      ChartDataPoint(label: '26/05', value: 72130176.26),
      ChartDataPoint(label: '27/05', value: 98130176.26),
      ChartDataPoint(label: '28/05', value: 110130176.26),
      ChartDataPoint(label: '29/05', value: 95130176.26),
      ChartDataPoint(label: '30/05', value: 120130176.26),
    ];
  }

  @override
  Future<List<ChartDataPoint>> getOrdersChart() async {
    return const [
      ChartDataPoint(label: '24/05', value: 55),
      ChartDataPoint(label: '25/05', value: 62),
      ChartDataPoint(label: '26/05', value: 48),
      ChartDataPoint(label: '27/05', value: 70),
      ChartDataPoint(label: '28/05', value: 80),
      ChartDataPoint(label: '29/05', value: 65),
      ChartDataPoint(label: '30/05', value: 90),
    ];
  }

  @override
  Future<List<EmployeeRank>> getTopEmployees() async {
    return const [
      EmployeeRank(id: '1', name: 'Alice Smith', department: 'Marketing', score: 95.0, avatar: 'AS'),
      EmployeeRank(id: '2', name: 'Bob Jones', department: 'Sales', score: 92.5, avatar: 'BJ'),
      EmployeeRank(id: '3', name: 'Charlie Brown', department: 'Operations', score: 88.0, avatar: 'CB'),
      EmployeeRank(id: '4', name: 'Diana Prince', department: 'Marketing', score: 85.0, avatar: 'DP'),
      EmployeeRank(id: '5', name: 'Ethan Hunt', department: 'Security', score: 82.0, avatar: 'EH'),
    ];
  }

  @override
  Future<List<DashboardAlert>> getAlerts() async {
    return const [
      DashboardAlert(id: '1', title: 'Critical Stock Out', body: 'Shopee item SKU-102 out of stock', time: '10m ago', severity: AlertSeverity.critical, isRead: false),
      DashboardAlert(id: '2', title: 'Late Shipping Warning', body: '3 orders pending shipment > 24h', time: '1h ago', severity: AlertSeverity.warning, isRead: false),
      DashboardAlert(id: '3', title: 'Daily Sync Success', body: 'Shopee order sync complete', time: '2h ago', severity: AlertSeverity.resolved, isRead: true),
    ];
  }

  @override
  Future<void> markAlertAsRead(String id) async {}
}

void main() {
  testWidgets('Dashboard renders successfully on mobile screen size', (WidgetTester tester) async {
    // Set screen size to standard mobile portrait (e.g. width=400, height=800)
    tester.view.physicalSize = const Size(400 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(
          dashboardService: MockDashboardService(),
        ),
      ),
    );

    // Initial render
    await tester.pump();
    // Wait for the fade-in animation (550ms)
    await tester.pump(const Duration(milliseconds: 600));

    // 1. Verify Top AppBar items
    expect(find.text('Ecommerce KPI'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

    // 2. Verify Statistics Cards
    expect(find.text("Today's Revenue"), findsOneWidget);
    expect(find.text("Monthly Revenue"), findsOneWidget);
    expect(find.text("Today's Orders"), findsOneWidget);
    expect(find.text("Average KPI"), findsOneWidget);
    expect(find.text("Active Employees"), findsOneWidget);
    expect(find.text("Current Alerts"), findsOneWidget);

    // Verify statistics values formatted correctly
    expect(find.text('36'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);

    // 3. Verify Custom Charts render
    expect(find.text('Revenue (7 Days)'), findsOneWidget);
    expect(find.text('Orders (7 Days)'), findsOneWidget);
    expect(find.text('KPI Distribution'), findsOneWidget);

    // 4. Verify Employee Leaderboard Top Performers list
    expect(find.text('Top 5 KPI Performers'), findsOneWidget);
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Bob Jones'), findsOneWidget);
    expect(find.text('Ethan Hunt'), findsOneWidget);

    // 5. Verify Latest Alerts Section
    expect(find.text('Latest Alerts'), findsOneWidget);
    expect(find.text('Critical (1)'), findsOneWidget);
    expect(find.text('Warning (1)'), findsOneWidget);
    expect(find.text('Resolved (1)'), findsOneWidget);

    // 6. Verify Bottom Navigation
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Employees'), findsOneWidget);
    expect(find.text('KPI'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Reset simulator view size
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Dashboard renders successfully on tablet landscape screen size', (WidgetTester tester) async {
    // Set screen size to standard tablet (e.g. width=1024, height=768)
    tester.view.physicalSize = const Size(1024 * 2, 768 * 2);
    tester.view.devicePixelRatio = 2.0;

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(
          dashboardService: MockDashboardService(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify critical elements render under tablet row/grid layout constraints
    expect(find.text('Ecommerce KPI'), findsOneWidget);
    expect(find.text('Top 5 KPI Performers'), findsOneWidget);
    expect(find.text('Latest Alerts'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
