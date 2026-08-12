import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce_kpi_mobile/screens/reward_screen.dart';
import 'package:ecommerce_kpi_mobile/screens/reward_detail_screen.dart';
import 'package:ecommerce_kpi_mobile/screens/reward_create_screen.dart';
import 'package:ecommerce_kpi_mobile/screens/reward_edit_screen.dart';
import 'package:ecommerce_kpi_mobile/services/reward_service.dart';
import 'package:ecommerce_kpi_mobile/models/reward.dart';

class MockRewardService extends RewardService {
  final List<Reward> mockRewards = [
    const Reward(
      id: '1',
      employeeId: '101',
      employeeName: 'Alice Smith',
      department: 'Marketing',
      period: 'monthly',
      kpiScore: 95.0,
      rewardAmount: 200000.0,
      rewardType: 'Cash Bonus',
      rewardStatus: 'Pending',
      createdAt: '2026-05-24T00:00:00Z',
    ),
    const Reward(
      id: '2',
      employeeId: '102',
      employeeName: 'Bob Jones',
      department: 'Sales',
      period: 'weekly',
      kpiScore: 82.0,
      rewardAmount: 100000.0,
      rewardType: 'Gift Voucher',
      rewardStatus: 'Approved',
      approvedBy: 'Marcus Aurelius',
      approvedAt: '2026-05-25T00:00:00Z',
      createdAt: '2026-05-24T00:00:00Z',
    ),
  ];

  @override
  Future<List<Reward>> getRewards() async {
    return mockRewards;
  }

  @override
  Future<Reward> getRewardById(String id) async {
    return mockRewards.firstWhere((r) => r.id == id, orElse: () => mockRewards.first);
  }

  @override
  Future<Map<String, dynamic>> getSummary() async {
    return {
      'total_reward_amount': 300000.0,
      'employees_rewarded': 2,
    };
  }

  @override
  Future<List<Reward>> getHistory() async {
    return mockRewards.where((r) => r.rewardStatus != 'Pending').toList();
  }

  @override
  Future<Reward> createReward(Map<String, dynamic> data) async {
    return Reward.fromJson({
      'id': '3',
      ...data,
    });
  }

  @override
  Future<Reward> updateReward(String id, Map<String, dynamic> data) async {
    return Reward.fromJson({
      'id': id,
      ...data,
    });
  }

  @override
  Future<Reward> approveReward(String id) async {
    final original = mockRewards.firstWhere((r) => r.id == id);
    return original.copyWith(rewardStatus: 'Approved', approvedBy: 'Manager', approvedAt: '2026-06-27T00:00:00Z');
  }

  @override
  Future<Reward> rejectReward(String id) async {
    final original = mockRewards.firstWhere((r) => r.id == id);
    return original.copyWith(rewardStatus: 'Rejected', approvedBy: 'Manager', approvedAt: '2026-06-27T00:00:00Z');
  }

  @override
  Future<void> deleteReward(String id) async {}
}

void main() {
  testWidgets('RewardScreen renders and filters successfully', (WidgetTester tester) async {
    final mockService = MockRewardService();
    final router = GoRouter(
      initialLocation: '/reward_screen',
      routes: [
        GoRoute(
          path: '/reward_screen',
          builder: (context, state) => RewardScreen(service: mockService),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    // Loading indicator check
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Content verified
    expect(find.text('Reward Management'), findsOneWidget);
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Bob Jones'), findsOneWidget);

    // Summary amount check (localized Currency)
    expect(find.textContaining('300.000'), findsOneWidget);

    // Filter interaction
    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.pump();
    expect(find.text('Alice Smith'), findsOneWidget);
    expect(find.text('Bob Jones'), findsNothing);
  });

  testWidgets('RewardDetailScreen renders info and handles approve/reject commands', (WidgetTester tester) async {
    final mockService = MockRewardService();
    final router = GoRouter(
      initialLocation: '/reward_detail/1',
      routes: [
        GoRoute(
          path: '/reward_detail/:id',
          builder: (context, state) => RewardDetailScreen(
            rewardId: state.pathParameters['id']!,
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

    expect(find.text('Reward Details'), findsOneWidget);
    expect(find.text('Alice Smith'), findsOneWidget);

    // Action buttons visible since status is Pending
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);

    // Approve interaction
    await tester.tap(find.text('Approve'));
    await tester.pump();

    // Verification check message popup
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('RewardCreateScreen validates inputs and submits', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockService = MockRewardService();
    final router = GoRouter(
      initialLocation: '/create',
      routes: [
        GoRoute(
          path: '/create',
          builder: (context, state) => RewardCreateScreen(service: mockService),
        ),
        GoRoute(
          path: '/reward_screen',
          builder: (context, state) => const Scaffold(body: Text('Rewards Page')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    expect(find.text('Recommend Reward'), findsOneWidget);

    // Trigger empty validation check
    await tester.tap(find.text('Propose Reward'));
    await tester.pump();

    expect(find.text('Please enter employee name'), findsOneWidget);
    expect(find.text('Please enter employee ID'), findsOneWidget);
    expect(find.text('Please enter KPI score'), findsOneWidget);
    expect(find.text('Please enter reward type'), findsOneWidget);
    expect(find.text('Please enter reward amount'), findsOneWidget);

    // Fill valid data
    await tester.enterText(find.widgetWithText(TextFormField, 'Employee Full Name'), 'Charlie Brown');
    await tester.enterText(find.widgetWithText(TextFormField, 'Employee ID'), '103');
    await tester.enterText(find.widgetWithText(TextFormField, 'KPI Score (%)'), '88.5');
    await tester.enterText(find.widgetWithText(TextFormField, 'Reward Type'), 'Extra Leave');
    await tester.enterText(find.widgetWithText(TextFormField, 'Reward Amount (VND)'), '1500000');
    await tester.pump();

    // Trigger save
    await tester.tap(find.text('Propose Reward'));
    await tester.pump();

    expect(find.text('Please enter employee name'), findsNothing);
  });

  testWidgets('RewardEditScreen preloads settings and updates successfully', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockService = MockRewardService();
    final router = GoRouter(
      initialLocation: '/edit/1',
      routes: [
        GoRoute(
          path: '/edit/:id',
          builder: (context, state) => RewardEditScreen(
            rewardId: state.pathParameters['id']!,
            service: mockService,
          ),
        ),
        GoRoute(
          path: '/reward_detail_screen/:id',
          builder: (context, state) => const Scaffold(body: Text('Reward Detail Page')),
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

    expect(find.text('Edit Reward Proposal'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Alice Smith'), findsOneWidget);

    // Edit and submit
    await tester.enterText(find.widgetWithText(TextFormField, 'Employee Full Name'), 'Alice Cooper');
    await tester.pump();

    await tester.tap(find.text('Update Proposal'));
    await tester.pump();

    expect(find.text('Please enter employee name'), findsNothing);
  });
}
