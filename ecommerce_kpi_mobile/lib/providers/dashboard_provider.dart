import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service;

  DashboardProvider({DashboardService? service})
      : _service = service ?? DashboardService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DashboardSummary _summary = DashboardSummary.empty();
  DashboardSummary get summary => _summary;

  List<ChartDataPoint> _revenue7Days = [];
  List<ChartDataPoint> get revenue7Days => _revenue7Days;

  List<ChartDataPoint> _orders7Days = [];
  List<ChartDataPoint> get orders7Days => _orders7Days;

  List<ChartDataPoint> _kpiDistribution = [];
  List<ChartDataPoint> get kpiDistribution => _kpiDistribution;

  List<EmployeeRank> _topEmployees = [];
  List<EmployeeRank> get topEmployees => _topEmployees;

  List<DashboardAlert> _allAlerts = [];
  List<DashboardAlert> get allAlerts => _allAlerts;

  List<DashboardAlert> get criticalAlerts =>
      _allAlerts.where((a) => a.severity == AlertSeverity.critical).toList();

  List<DashboardAlert> get warningAlerts =>
      _allAlerts.where((a) => a.severity == AlertSeverity.warning).toList();

  List<DashboardAlert> get resolvedAlerts =>
      _allAlerts.where((a) => a.severity == AlertSeverity.resolved).toList();

  Future<void> loadDashboardData({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _service.getSummary(),
        _service.getRevenueChart(),
        _service.getOrdersChart(),
        _service.getTopEmployees(),
        _service.getAlerts(),
      ]);

      _summary = results[0] as DashboardSummary;
      _revenue7Days = results[1] as List<ChartDataPoint>;
      _orders7Days = results[2] as List<ChartDataPoint>;
      _topEmployees = results[3] as List<EmployeeRank>;
      _allAlerts = results[4] as List<DashboardAlert>;

      // Calculate KPI Distribution dynamically from topEmployees or employees list
      _calculateKpiDistribution();

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateKpiDistribution() {
    int bracketA = 0; // >= 90
    int bracketB = 0; // 80 - 89
    int bracketC = 0; // 70 - 79
    int bracketD = 0; // < 70

    // Since we only retrieve top 5 employees from getTopEmployees,
    // let's categorize them. If empty, populate with default ratios.
    if (_topEmployees.isEmpty) {
      _kpiDistribution = const [
        ChartDataPoint(label: 'Excellent (>=90)', value: 40),
        ChartDataPoint(label: 'Good (80-89)', value: 35),
        ChartDataPoint(label: 'Average (70-79)', value: 15),
        ChartDataPoint(label: 'Below ( <70)', value: 10),
      ];
      return;
    }

    for (var emp in _topEmployees) {
      final score = emp.score;
      if (score >= 90) {
        bracketA++;
      } else if (score >= 80) {
        bracketB++;
      } else if (score >= 70) {
        bracketC++;
      } else {
        bracketD++;
      }
    }

    final total = bracketA + bracketB + bracketC + bracketD;
    if (total == 0) {
      _kpiDistribution = const [
        ChartDataPoint(label: 'Excellent (>=90)', value: 40),
        ChartDataPoint(label: 'Good (80-89)', value: 35),
        ChartDataPoint(label: 'Average (70-79)', value: 15),
        ChartDataPoint(label: 'Below ( <70)', value: 10),
      ];
    } else {
      _kpiDistribution = [
        ChartDataPoint(label: 'Excellent (>=90)', value: (bracketA / total) * 100),
        ChartDataPoint(label: 'Good (80-89)', value: (bracketB / total) * 100),
        ChartDataPoint(label: 'Average (70-79)', value: (bracketC / total) * 100),
        ChartDataPoint(label: 'Below ( <70)', value: (bracketD / total) * 100),
      ];
    }
  }

  Future<void> markAlertAsRead(String id) async {
    try {
      await _service.markAlertAsRead(id);
      // Update local state list
      _allAlerts = _allAlerts.map((alert) {
        if (alert.id == id) {
          return DashboardAlert(
            id: alert.id,
            title: alert.title,
            body: alert.body,
            time: alert.time,
            severity: alert.severity,
            isRead: true,
          );
        }
        return alert;
      }).toList();
      notifyListeners();
    } catch (_) {
      // Fallback update in case of mock exceptions
      _allAlerts = _allAlerts.map((alert) {
        if (alert.id == id) {
          return DashboardAlert(
            id: alert.id,
            title: alert.title,
            body: alert.body,
            time: alert.time,
            severity: alert.severity,
            isRead: true,
          );
        }
        return alert;
      }).toList();
      notifyListeners();
    }
  }
}
