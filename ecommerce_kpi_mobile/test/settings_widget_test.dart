import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce_kpi_mobile/screens/settings_screen.dart';
import 'package:ecommerce_kpi_mobile/services/settings_service.dart';
import 'package:ecommerce_kpi_mobile/models/settings.dart';

class MockSettingsService extends SettingsService {
  ManagerSettings mockSettings = const ManagerSettings(
    managerName: 'Alice Smith',
    email: 'alice@shopee-kpi.com',
    phone: '0912345678',
    avatar: '',
    language: 'English',
    themeMode: 'System',
    notificationEnabled: true,
    biometricEnabled: false,
    appVersion: '1.2.3',
  );

  @override
  Future<ManagerSettings> getProfile() async {
    return mockSettings;
  }

  @override
  Future<ManagerSettings> updateProfile(ManagerSettings settings) async {
    mockSettings = settings;
    return mockSettings;
  }

  @override
  Future<Map<String, dynamic>> updatePreferences(ManagerSettings settings) async {
    mockSettings = settings;
    return {
      'language': settings.language,
      'theme_mode': settings.themeMode,
      'notification_enabled': settings.notificationEnabled,
      'biometric_enabled': settings.biometricEnabled,
    };
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    // Success path
  }
}

void main() {
  testWidgets('SettingsScreen loads, updates switches, and saves successfully', (WidgetTester tester) async {
    final mockService = MockSettingsService();
    final router = GoRouter(
      initialLocation: '/settings_screen',
      routes: [
        GoRoute(
          path: '/settings_screen',
          builder: (context, state) => SettingsScreen(service: mockService),
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

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Alice Smith'), findsNWidgets(2));
    expect(find.text('alice@shopee-kpi.com'), findsNWidgets(2));
    expect(find.text('App Version: 1.2.3'), findsOneWidget);

    // Verify initial switch values
    final pushSwitchFinder = find.byType(Switch).first;
    Switch pushSwitch = tester.widget<Switch>(pushSwitchFinder);
    expect(pushSwitch.value, isFalse); // themeMode is System, so dark mode is false

    // Tap switch to toggle preference
    await tester.tap(pushSwitchFinder);
    await tester.pumpAndSettle();
    expect(mockService.mockSettings.themeMode, 'Dark');

    // Change Name field
    final nameFieldFinder = find.widgetWithText(TextFormField, 'Full Name');
    expect(nameFieldFinder, findsOneWidget);
    await tester.enterText(nameFieldFinder, 'Alice Cooper');

    // Drag list down to make Save button visible
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();

    // Click Save Personal Information
    final saveBtnFinder = find.widgetWithText(ElevatedButton, 'Save Personal Information');
    await tester.tap(saveBtnFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(mockService.mockSettings.managerName, 'Alice Cooper');
  });

  testWidgets('SettingsScreen triggers logout and navigates to login', (WidgetTester tester) async {
    final mockService = MockSettingsService();
    final router = GoRouter(
      initialLocation: '/settings_screen',
      routes: [
        GoRoute(
          path: '/settings_screen',
          builder: (context, state) => SettingsScreen(service: mockService),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Screen')),
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

    // Drag list down to make Logout button visible
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    final logoutTileFinder = find.widgetWithText(ListTile, 'Logout').first;
    await tester.tap(logoutTileFinder, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Login Screen'), findsOneWidget);
  });
}
