import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce_kpi_mobile/screens/employee_list_screen.dart';
import 'package:ecommerce_kpi_mobile/screens/employee_detail_screen.dart';
import 'package:ecommerce_kpi_mobile/screens/employee_create_screen.dart';
import 'package:ecommerce_kpi_mobile/screens/employee_edit_screen.dart';
import 'package:ecommerce_kpi_mobile/services/employee_service.dart';
import 'package:ecommerce_kpi_mobile/models/employee.dart';

class MockEmployeeService extends EmployeeService {
  final List<Employee> mockEmployees = [
    const Employee(
      id: '1',
      employeeCode: 'EMP001',
      fullName: 'Alice Smith',
      email: 'alice@ecommercekpi.com',
      phone: '0123456789',
      role: 'Employee',
      department: 'Marketing',
      platform: 'Shopee',
      status: 'Active',
      todayRevenue: 24000000,
      todayOrders: 12,
      todayKpi: 95.0,
      bonus: 200000,
      avatar: 'AS',
      createdAt: '2026-05-24T00:00:00Z',
    ),
    const Employee(
      id: '2',
      employeeCode: 'EMP002',
      fullName: 'Bob Jones',
      email: 'bob@ecommercekpi.com',
      phone: '0987654321',
      role: 'Manager',
      department: 'Sales',
      platform: 'Shopee',
      status: 'Inactive',
      todayRevenue: 10000000,
      todayOrders: 5,
      todayKpi: 80.0,
      bonus: 0,
      avatar: 'BJ',
      createdAt: '2026-05-24T00:00:00Z',
    ),
  ];

  @override
  Future<List<Employee>> getEmployees() async {
    return mockEmployees;
  }

  @override
  Future<Employee> getEmployeeById(String id) async {
    return mockEmployees.firstWhere((emp) => emp.id == id, orElse: () => mockEmployees.first);
  }

  @override
  Future<Employee> createEmployee(Map<String, dynamic> data) async {
    return Employee.fromJson({
      'id': '3',
      'employee_code': 'EMP003',
      ...data,
      'today_revenue': 0.0,
      'today_orders': 0,
      'today_kpi': 0.0,
      'bonus': 0.0,
    });
  }

  @override
  Future<Employee> updateEmployee(String id, Map<String, dynamic> data) async {
    return Employee.fromJson({
      'id': id,
      'employee_code': 'EMP001',
      ...data,
      'today_revenue': 24000000.0,
      'today_orders': 12,
      'today_kpi': 95.0,
      'bonus': 200000.0,
    });
  }

  @override
  Future<void> deleteEmployee(String id) async {}

  @override
  Future<Employee> changeStatus(String id, String status) async {
    final original = mockEmployees.firstWhere((emp) => emp.id == id);
    return original.copyWith(status: status);
  }
}

void main() {
  testWidgets('EmployeeListScreen renders and filters successfully', (WidgetTester tester) async {
    final mockService = MockEmployeeService();
    final router = GoRouter(
      initialLocation: '/employees',
      routes: [
        GoRoute(
          path: '/employees',
          builder: (context, state) => EmployeeListScreen(service: mockService),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    // Initial loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Loaded state verification
    expect(find.text('Employee Directory'), findsOneWidget);
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Bob Jones'), findsOneWidget);

    // Search input test
    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.pump();
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Bob Jones'), findsNothing);

    // Clear search test
    await tester.tap(find.byIcon(Icons.clear_rounded));
    await tester.pump();
    expect(find.text('Bob Jones'), findsOneWidget);
  });

  testWidgets('EmployeeDetailScreen renders statistics and details', (WidgetTester tester) async {
    final mockService = MockEmployeeService();
    final router = GoRouter(
      initialLocation: '/employees/1',
      routes: [
        GoRoute(
          path: '/employees/:id',
          builder: (context, state) => EmployeeDetailScreen(
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

    // Title and Info
    expect(find.text('Employee Details'), findsOneWidget);
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Marketing'), findsAtLeastNWidgets(1));

    // Custom stats values checks
    expect(find.text('95.0%'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);

    // Buttons
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Disable'), findsOneWidget);
    expect(find.text('Delete Employee'), findsOneWidget);
  });

  testWidgets('EmployeeCreateScreen validates input and submits form', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockService = MockEmployeeService();
    final router = GoRouter(
      initialLocation: '/create',
      routes: [
        GoRoute(
          path: '/create',
          builder: (context, state) => EmployeeCreateScreen(service: mockService),
        ),
        GoRoute(
          path: '/employees',
          builder: (context, state) => const Scaffold(body: Text('Employees List Page')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    expect(find.text('Add Employee'), findsOneWidget);

    // Trigger validation
    await tester.tap(find.text('Save Employee'));
    await tester.pump();

    expect(find.text('Please enter name'), findsOneWidget);
    expect(find.text('Please enter email'), findsOneWidget);
    expect(find.text('Please enter phone number'), findsOneWidget);

    // Fill details
    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'John Doe');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email Address'), 'john.doe@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '0999999999');
    await tester.pump();

    // Trigger validation again (errors should disappear)
    await tester.tap(find.text('Save Employee'));
    await tester.pump();

    expect(find.text('Please enter name'), findsNothing);
    expect(find.text('Please enter email'), findsNothing);
    expect(find.text('Please enter phone number'), findsNothing);
  });

  testWidgets('EmployeeEditScreen preloads data and submits successfully', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockService = MockEmployeeService();
    final router = GoRouter(
      initialLocation: '/edit/1',
      routes: [
        GoRoute(
          path: '/edit/:id',
          builder: (context, state) => EmployeeEditScreen(
            employeeId: state.pathParameters['id']!,
            service: mockService,
          ),
        ),
        GoRoute(
          path: '/employees/:id',
          builder: (context, state) => const Scaffold(body: Text('Employee Detail Page')),
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

    expect(find.text('Edit Employee'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Alice Smith'), findsOneWidget);

    // Edit Name
    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'Alice Johnson');
    await tester.pump();

    await tester.tap(find.text('Update Employee'));
    await tester.pump();

    expect(find.text('Please enter name'), findsNothing);
  });
}
