import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce_kpi_mobile/screens/kpi_screen.dart';
import 'package:ecommerce_kpi_mobile/screens/kpi_detail_screen.dart';
import 'package:ecommerce_kpi_mobile/services/kpi_service.dart';
import 'package:ecommerce_kpi_mobile/models/kpi.dart';

class MockKpiService extends KpiService {
  final List<Kpi> mockKpiList = [
    const Kpi(
      employeeId: '1',
      employeeName: 'Alice Smith',
      department: 'Marketing',
      todayRevenue: 24000000.0,
      todayOrders: 12,
      completedOrders: 10,
      cancelledOrders: 1,
      lateOrders: 1,
      responseRate: 98.0,
      responseTime: 1.5,
      newProducts: 5,
      updatedProducts: 2,
      kpiOrder: 95.0,
      kpiChat: 99.0,
      kpiProduct: 90.0,
      kpiRevenue: 96.0,
      totalKpi: 95.0,
      rank: 1,
      rewardEstimate: 200000.0,
      createdAt: '2026-05-24T00:00:00Z',
    ),
    const Kpi(
      employeeId: '2',
      employeeName: 'Bob Jones',
      department: 'Sales',
      todayRevenue: 10000000.0,
      todayOrders: 5,
      completedOrders: 4,
      cancelledOrders: 0,
      lateOrders: 1,
      responseRate: 85.0,
      responseTime: 3.2,
      newProducts: 2,
      updatedProducts: 0,
      kpiOrder: 80.0,
      kpiChat: 82.0,
      kpiProduct: 85.0,
      kpiRevenue: 81.0,
      totalKpi: 82.0,
      rank: 2,
      rewardEstimate: 0.0,
      createdAt: '2026-05-24T00:00:00Z',
    ),
  ];

  @override
  Future<List<Kpi>> getTodayKpi() async {
    return mockKpiList;
  }

  @override
  Future<List<Kpi>> getWeekKpi() async {
    return mockKpiList;
  }

  @override
  Future<List<Kpi>> getMonthKpi() async {
    return mockKpiList;
  }

  @override
  Future<Kpi> getEmployeeKpi(String employeeId) async {
    return mockKpiList.firstWhere((k) => k.employeeId == employeeId, orElse: () => mockKpiList.first);
  }

  @override
  Future<List<Kpi>> getKpiRanking() async {
    return mockKpiList;
  }
}

void main() {
  testWidgets('KpiScreen renders and loads data successfully', (WidgetTester tester) async {
    final mockService = MockKpiService();
    final router = GoRouter(
      initialLocation: '/kpi_screen',
      routes: [
        GoRoute(
          path: '/kpi_screen',
          builder: (context, state) => KpiScreen(service: mockService),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    // Verify loading spinner
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify UI components
    expect(find.text('KPI Management'), findsOneWidget);
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Bob Jones'), findsOneWidget);

    // Period toggler interaction
    await tester.tap(find.text('Week'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Search input
    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.pump();
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Bob Jones'), findsNothing);
  });

  testWidgets('KpiDetailScreen renders circular charts and detailed statistics', (WidgetTester tester) async {
    final mockService = MockKpiService();
    final router = GoRouter(
      initialLocation: '/kpi_detail_screen/1',
      routes: [
        GoRoute(
          path: '/kpi_detail_screen/:id',
          builder: (context, state) => KpiDetailScreen(
            employeeId: state.pathParameters['id']!,
            service: mockService,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Header and name info
    expect(find.text('KPI Performance Profile'), findsOneWidget);
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Position Rank: #1 | Marketing'), findsOneWidget);

    // Check component targets
    expect(find.text('Revenue Target'), findsOneWidget);
    expect(find.text('Orders Fulfillment'), findsOneWidget);
    expect(find.text('Chat Communications'), findsOneWidget);
    expect(find.text('Products Management'), findsOneWidget);

    // Check circular progress percentage overall KPI
    expect(find.text('95.0%'), findsOneWidget);

    // Check rewards estimate
    expect(find.textContaining('200.000'), findsOneWidget);
  });
}
