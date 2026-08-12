import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce_kpi_mobile/screens/report_screen.dart';
import 'package:ecommerce_kpi_mobile/screens/report_detail_screen.dart';
import 'package:ecommerce_kpi_mobile/services/report_service.dart';
import 'package:ecommerce_kpi_mobile/models/report.dart';
import 'package:ecommerce_kpi_mobile/widgets/report_chart.dart';

class MockReportService extends ReportService {
  final List<Report> mockReports = [
    const Report(
      id: '1',
      title: 'May Sales Performance Report',
      reportType: 'General',
      platform: 'Shopee',
      period: 'Monthly',
      generatedAt: '2026-05-31T23:59:59Z',
      totalRevenue: 5000000.0,
      totalOrders: 100,
      completedOrders: 90,
      cancelledOrders: 8,
      returnOrders: 2,
      averageOrderValue: 50000.0,
      topEmployee: 'Alice Smith',
      topProduct: 'Shopee Voucher A',
      status: 'Completed',
    ),
  ];

  @override
  Future<List<Report>> getReports() async {
    return mockReports;
  }

  @override
  Future<Report> getReportById(String id) async {
    return mockReports.firstWhere((r) => r.id == id, orElse: () => mockReports.first);
  }

  @override
  Future<Map<String, dynamic>> getSummary() async {
    return {
      'total_revenue': 5000000.0,
      'total_orders': 100,
      'completed_orders': 90,
      'cancelled_orders': 8,
      'average_order_value': 50000.0,
    };
  }

  @override
  Future<List<dynamic>> getRevenueTrends() async {
    return [
      {'date': 'W1', 'revenue': 1200000.0},
      {'date': 'W2', 'revenue': 1800000.0},
      {'date': 'W3', 'revenue': 1500000.0},
      {'date': 'W4', 'revenue': 2200000.0},
    ];
  }

  @override
  Future<List<dynamic>> getOrdersTrends() async {
    return [
      {'date': 'W1', 'orders': 15},
      {'date': 'W2', 'orders': 25},
      {'date': 'W3', 'orders': 20},
      {'date': 'W4', 'orders': 32},
    ];
  }

  @override
  Future<List<dynamic>> getProductsStats() async {
    return [
      {'product_name': 'Shopee Voucher A', 'quantity': 120, 'revenue': 600000.0},
    ];
  }

  @override
  Future<List<dynamic>> getEmployeesStats() async {
    return [
      {'employee_name': 'Alice Smith', 'department': 'Marketing', 'kpi_score': 95.0, 'revenue': 1500000.0},
    ];
  }
}

void main() {
  testWidgets('ReportScreen renders and updates statistics filters', (WidgetTester tester) async {
    final mockService = MockReportService();
    final router = GoRouter(
      initialLocation: '/report_screen',
      routes: [
        GoRoute(
          path: '/report_screen',
          builder: (context, state) => ReportScreen(service: mockService),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Reports & Analytics'), findsOneWidget);
    expect(find.text('May Sales Performance Report'), findsOneWidget);

    // Summary checks
    expect(find.textContaining('5.000.000'), findsOneWidget);
    expect(find.text('90'), findsOneWidget); // Completed orders count

    // Custom charts checks
    expect(find.byType(ReportChart), findsNWidgets(2));
  });

  testWidgets('ReportDetailScreen renders metrics breakdown and averages', (WidgetTester tester) async {
    final mockService = MockReportService();
    final router = GoRouter(
      initialLocation: '/detail/1',
      routes: [
        GoRoute(
          path: '/detail/:id',
          builder: (context, state) => ReportDetailScreen(
            reportId: state.pathParameters['id']!,
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

    expect(find.text('Report Overview'), findsOneWidget);
    expect(find.text('May Sales Performance Report'), findsOneWidget);

    // Financial breakdown values
    expect(find.textContaining('5.000.000'), findsOneWidget);
    expect(find.textContaining('50.000'), findsOneWidget); // AOV

    // Best performers
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Shopee Voucher A'), findsOneWidget);
  });
}
