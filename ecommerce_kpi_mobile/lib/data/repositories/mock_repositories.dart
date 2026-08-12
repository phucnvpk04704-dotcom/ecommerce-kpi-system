import 'auth_repository.dart';
import '../services/secure_storage_service.dart';

class MockAuthRepository implements AuthRepository {
  final SecureStorageService storageService;

  MockAuthRepository({required this.storageService});

  @override
  Future<String> login({required String username, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network latency
    if (username.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Username and password cannot be empty');
    }
    const token = 'mock_jwt_token_burgundy_enterprise_12345';
    await storageService.writeToken(token);
    await storageService.writeUser('{"name": "Marcus Aurelius", "email": "marcus.aurelius@burgundy.com", "role": "E-Commerce Director", "department": "Operations"}');
    return token;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await storageService.deleteToken();
    await storageService.deleteUser();
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userJson = await storageService.readUser();
    if (userJson != null) {
      return {
        "name": "Marcus Aurelius",
        "email": "marcus.aurelius@burgundy.com",
        "role": "E-Commerce Director",
        "department": "Operations"
      };
    }
    return null;
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await storageService.readToken();
    return token != null && token.isNotEmpty;
  }
}

class MockDashboardRepository {
  Future<Map<String, dynamic>> getKPIOverview() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      "total_revenue": 1420500.0,
      "revenue_target": 1500000.0,
      "average_kpi": 88.5,
      "rewards_distributed": 24,
      "blacklisted_count": 8,
      "active_employees": 42
    };
  }

  Future<List<Map<String, dynamic>>> getRevenues() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {"month": "Jan", "revenue": 120000.0, "target": 110000.0},
      {"month": "Feb", "revenue": 135000.0, "target": 120000.0},
      {"month": "Mar", "revenue": 150000.0, "target": 130000.0},
      {"month": "Apr", "revenue": 145000.0, "target": 140000.0},
      {"month": "May", "revenue": 160000.0, "target": 150000.0},
      {"month": "Jun", "revenue": 185000.0, "target": 160000.0},
      {"month": "Jul", "revenue": 195000.0, "target": 170000.0},
      {"month": "Aug", "revenue": 210000.0, "target": 180000.0},
      {"month": "Sep", "revenue": 225000.0, "target": 190000.0},
    ];
  }

  // Helper mock data methods to power other feature screens
  Future<List<Map<String, dynamic>>> getEmployeesKPI() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {"name": "Alice Smith", "department": "Marketing", "kpi": 94.5, "sales": 45000.0, "avatar": "AS"},
      {"name": "Bob Johnson", "department": "Sales", "kpi": 82.0, "sales": 38000.0, "avatar": "BJ"},
      {"name": "Charlie Brown", "department": "Customer Support", "kpi": 91.0, "sales": 0.0, "avatar": "CB"},
      {"name": "Diana Prince", "department": "Logistics", "kpi": 98.2, "sales": 55000.0, "avatar": "DP"},
      {"name": "Evan Wright", "department": "Development", "kpi": 78.5, "sales": 0.0, "avatar": "EW"},
      {"name": "Fiona Gallagher", "department": "Marketing", "kpi": 88.0, "sales": 32000.0, "avatar": "FG"},
    ];
  }

  Future<List<Map<String, dynamic>>> getRewards() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {"title": "Elite Performer of Q2", "description": "Achieve over 120% of sales KPI target", "reward": "\$1,000 Cash Bonus", "status": "Active"},
      {"title": "Customer Champion", "description": "Maintain CSAT score above 95% for 3 months", "reward": "\$500 Gift Voucher", "status": "Claimed"},
      {"title": "Productivity Master", "description": "Zero log delays and 100% task completion", "reward": "Extra 3 Paid Days Off", "status": "Active"},
      {"title": "Logistics Hero", "description": "Reduce transit delay metrics by 15%", "reward": "\$300 Amazon Card", "status": "Expired"},
    ];
  }

  Future<List<Map<String, dynamic>>> getBlacklist() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {"name": "John Doe Corp", "reason": "Consistent payment default and chargeback fraud", "date": "2026-03-12", "risk": "High"},
      {"name": "Jane Miller", "reason": "Multiple fraudulent voucher code applications", "date": "2026-04-05", "risk": "Medium"},
      {"name": "Arthur Pendragon", "reason": "Abusive behavior towards support staff", "date": "2026-05-20", "risk": "Low"},
      {"name": "Morgana Le Fay", "reason": "Carding activity and fake credit cards", "date": "2026-06-01", "risk": "High"},
      {"name": "Lancelot Logistics Ltd", "reason": "Non-delivery of goods & contract breach", "date": "2026-06-15", "risk": "High"},
    ];
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {"rank": 1, "name": "Diana Prince", "kpi": 98.2, "sales": 55000.0, "avatar": "DP"},
      {"rank": 2, "name": "Alice Smith", "kpi": 94.5, "sales": 45000.0, "avatar": "AS"},
      {"rank": 3, "name": "Charlie Brown", "kpi": 91.0, "sales": 32000.0, "avatar": "CB"},
      {"rank": 4, "name": "Fiona Gallagher", "kpi": 88.0, "sales": 32000.0, "avatar": "FG"},
      {"rank": 5, "name": "Bob Johnson", "kpi": 82.0, "sales": 38000.0, "avatar": "BJ"},
    ];
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      {"title": "Monthly Target Exceeded", "body": "Marketing team surpassed the sales target by 14%!", "time": "2 hours ago", "type": "success", "read": false},
      {"title": "High Risk Customer Blacklisted", "body": "Morgana Le Fay was added to the blacklist due to carding activity.", "time": "1 day ago", "type": "warning", "read": false},
      {"title": "System Maintenance Scheduled", "body": "KPI Portal will be offline for 30 minutes on Saturday at 2 AM.", "time": "2 days ago", "type": "info", "read": true},
    ];
  }
}
