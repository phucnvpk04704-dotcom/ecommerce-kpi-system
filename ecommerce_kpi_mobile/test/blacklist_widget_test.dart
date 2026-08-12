import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce_kpi_mobile/screens/blacklist_screen.dart';
import 'package:ecommerce_kpi_mobile/screens/blacklist_detail_screen.dart';
import 'package:ecommerce_kpi_mobile/screens/blacklist_create_screen.dart';
import 'package:ecommerce_kpi_mobile/screens/blacklist_edit_screen.dart';
import 'package:ecommerce_kpi_mobile/services/blacklist_service.dart';
import 'package:ecommerce_kpi_mobile/models/blacklist_customer.dart';

class MockBlacklistService extends BlacklistService {
  final List<BlacklistCustomer> mockCustomers = [
    const BlacklistCustomer(
      id: '1',
      customerName: 'John Doe',
      phone: '0987654321',
      platform: 'Shopee',
      riskLevel: 'High',
      cancelCount: 5,
      returnCount: 2,
      complaintCount: 1,
      lastOrderDate: '2026-06-25',
      lastViolationDate: '2026-06-26',
      status: 'Active',
      note: 'Suspicious card attempts',
    ),
    const BlacklistCustomer(
      id: '2',
      customerName: 'Mary Jane',
      phone: '0123456789',
      platform: 'Lazada',
      riskLevel: 'Warning',
      cancelCount: 2,
      returnCount: 0,
      complaintCount: 0,
      lastOrderDate: '2026-06-20',
      lastViolationDate: '2026-06-21',
      status: 'Resolved',
      note: 'Voucher abuse pattern detected',
    ),
  ];

  @override
  Future<List<BlacklistCustomer>> getBlacklist() async {
    return mockCustomers;
  }

  @override
  Future<BlacklistCustomer> getCustomerById(String id) async {
    return mockCustomers.firstWhere((c) => c.id == id, orElse: () => mockCustomers.first);
  }

  @override
  Future<Map<String, dynamic>> getStatistics() async {
    return {
      'total_blacklist': 2,
      'high_risk_count': 1,
      'warning_risk_count': 1,
    };
  }

  @override
  Future<BlacklistCustomer> createCustomer(Map<String, dynamic> data) async {
    return BlacklistCustomer.fromJson({
      'id': '3',
      ...data,
    });
  }

  @override
  Future<BlacklistCustomer> updateCustomer(String id, Map<String, dynamic> data) async {
    return BlacklistCustomer.fromJson({
      'id': id,
      ...data,
    });
  }

  @override
  Future<BlacklistCustomer> changeStatus(String id, String status) async {
    final original = mockCustomers.firstWhere((c) => c.id == id);
    return original.copyWith(status: status);
  }

  @override
  Future<void> deleteCustomer(String id) async {}
}

void main() {
  testWidgets('BlacklistScreen renders and filters successfully', (WidgetTester tester) async {
    final mockService = MockBlacklistService();
    final router = GoRouter(
      initialLocation: '/blacklist_screen',
      routes: [
        GoRoute(
          path: '/blacklist_screen',
          builder: (context, state) => BlacklistScreen(service: mockService),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    // Initial load
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Content verified
    expect(find.text('Blacklist Management'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Mary Jane'), findsOneWidget);

    // Summary checks
    expect(find.text('2'), findsOneWidget); // Total count
    expect(find.text('1'), findsNWidgets(2)); // High risk (1) & Warning (1)

    // Filter search interaction
    await tester.enterText(find.byType(TextField), 'John');
    await tester.pump();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Mary Jane'), findsNothing);
  });

  testWidgets('BlacklistDetailScreen renders profile information and resolves status', (WidgetTester tester) async {
    final mockService = MockBlacklistService();
    final router = GoRouter(
      initialLocation: '/detail/1',
      routes: [
        GoRoute(
          path: '/detail/:id',
          builder: (context, state) => BlacklistDetailScreen(
            customerId: state.pathParameters['id']!,
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

    expect(find.text('Blacklist Details'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Suspicious card attempts'), findsOneWidget);

    // Resolve Alert button check
    expect(find.text('Resolve Alert Status'), findsOneWidget);

    // Tap resolve status
    await tester.tap(find.text('Resolve Alert Status'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('BlacklistCreateScreen validates and submits blacklist profile', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockService = MockBlacklistService();
    final router = GoRouter(
      initialLocation: '/create',
      routes: [
        GoRoute(
          path: '/create',
          builder: (context, state) => BlacklistCreateScreen(service: mockService),
        ),
        GoRoute(
          path: '/blacklist_screen',
          builder: (context, state) => const Scaffold(body: Text('Blacklist Page')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    expect(find.text('Add Blacklist Customer'), findsOneWidget);

    // Trigger validation
    await tester.tap(find.text('Save Customer Profile'));
    await tester.pump();

    expect(find.text('Please enter customer name'), findsOneWidget);
    expect(find.text('Please enter phone number'), findsOneWidget);

    // Fill valid data
    await tester.enterText(find.widgetWithText(TextFormField, 'Customer Full Name'), 'Bruce Wayne');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '0999888777');
    await tester.pump();

    // Trigger save
    await tester.tap(find.text('Save Customer Profile'));
    await tester.pump();

    expect(find.text('Please enter customer name'), findsNothing);
  });

  testWidgets('BlacklistEditScreen preloads inputs and updates successfully', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockService = MockBlacklistService();
    final router = GoRouter(
      initialLocation: '/edit/1',
      routes: [
        GoRoute(
          path: '/edit/:id',
          builder: (context, state) => BlacklistEditScreen(
            customerId: state.pathParameters['id']!,
            service: mockService,
          ),
        ),
        GoRoute(
          path: '/blacklist_detail_screen/:id',
          builder: (context, state) => const Scaffold(body: Text('Detail Page')),
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

    expect(find.text('Edit Blacklist Customer'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'John Doe'), findsOneWidget);

    // Submit edit
    await tester.tap(find.text('Update Customer Profile'));
    await tester.pump();

    expect(find.text('Please enter customer name'), findsNothing);
  });
}
