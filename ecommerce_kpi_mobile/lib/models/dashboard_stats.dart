class DashboardSummary {
  final double todayRevenue;
  final double monthlyRevenue;
  final int todayOrders;
  final double averageKpi;
  final int activeEmployees;
  final int currentAlerts;

  const DashboardSummary({
    required this.todayRevenue,
    required this.monthlyRevenue,
    required this.todayOrders,
    required this.averageKpi,
    required this.activeEmployees,
    required this.currentAlerts,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json, {double avgKpi = 0.0, int alertCount = 0}) {
    return DashboardSummary(
      todayRevenue: double.tryParse(json['revenue_today']?.toString() ?? '0.0') ?? 0.0,
      monthlyRevenue: double.tryParse(json['total_revenue']?.toString() ?? '0.0') ?? 0.0,
      todayOrders: json['orders_today'] as int? ?? json['total_orders'] as int? ?? 0,
      averageKpi: avgKpi,
      activeEmployees: json['total_employees'] as int? ?? 0,
      currentAlerts: alertCount,
    );
  }

  factory DashboardSummary.empty() {
    return const DashboardSummary(
      todayRevenue: 0.0,
      monthlyRevenue: 0.0,
      todayOrders: 0,
      averageKpi: 0.0,
      activeEmployees: 0,
      currentAlerts: 0,
    );
  }
}

class ChartDataPoint {
  final String label;
  final double value;

  const ChartDataPoint({
    required this.label,
    required this.value,
  });
}

enum AlertSeverity {
  critical,
  warning,
  resolved,
}

class DashboardAlert {
  final String id;
  final String title;
  final String body;
  final String time;
  final AlertSeverity severity;
  final bool isRead;

  const DashboardAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.severity,
    required this.isRead,
  });

  factory DashboardAlert.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] ?? 'info').toString().toLowerCase();
    AlertSeverity severity = AlertSeverity.warning;
    if (typeStr == 'critical' || typeStr == 'error') {
      severity = AlertSeverity.critical;
    } else if (typeStr == 'resolved' || typeStr == 'info' && json['title']?.toString().toLowerCase().contains('resolved') == true) {
      severity = AlertSeverity.resolved;
    }

    return DashboardAlert(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Alert',
      body: json['body']?.toString() ?? '',
      time: json['time']?.toString() ?? 'Just now',
      severity: severity,
      isRead: json['read'] as bool? ?? false,
    );
  }
}

class EmployeeRank {
  final String id;
  final String name;
  final String department;
  final double score;
  final String avatar;

  const EmployeeRank({
    required this.id,
    required this.name,
    required this.department,
    required this.score,
    required this.avatar,
  });

  factory EmployeeRank.fromJson(Map<String, dynamic> json) {
    return EmployeeRank(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? 'Unknown',
      department: json['department'] ?? 'Marketing',
      score: (json['kpi'] as num?)?.toDouble() ?? 0.0,
      avatar: json['avatar'] ?? (json['full_name'] != null && json['full_name'].toString().isNotEmpty
          ? json['full_name'].toString().substring(0, 2).toUpperCase()
          : 'EM'),
    );
  }
}
