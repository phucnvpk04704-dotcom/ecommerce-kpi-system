import 'package:flutter/material.dart';
import '../models/report.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _service;

  ReportProvider({ReportService? service})
      : _service = service ?? ReportService();

  bool _loading = false;
  bool get loading => _loading;

  List<Report> _rawReports = [];
  Report? _selectedReport;
  Report? get selectedReport => _selectedReport;

  Map<String, dynamic> _summary = {
    'total_revenue': 0.0,
    'total_orders': 0,
    'completed_orders': 0,
    'cancelled_orders': 0,
    'average_order_value': 0.0,
  };
  Map<String, dynamic> get summary => _summary;

  List<dynamic> _revenueData = [];
  List<dynamic> get revenueData => _revenueData;

  List<dynamic> _ordersData = [];
  List<dynamic> get ordersData => _ordersData;

  List<dynamic> _employeeData = [];
  List<dynamic> get employeeData => _employeeData;

  List<dynamic> _productData = [];
  List<dynamic> get productData => _productData;

  String _platform = 'All';
  String get platform => _platform;

  String _period = 'All';
  String get period => _period;

  String? _error;
  String? get error => _error;

  List<Report> get reports {
    List<Report> filtered = List.from(_rawReports);

    if (_platform != 'All') {
      filtered = filtered.where((r) => r.platform.toLowerCase() == _platform.toLowerCase()).toList();
    }

    if (_period != 'All') {
      filtered = filtered.where((r) => r.period.toLowerCase() == _period.toLowerCase()).toList();
    }

    return filtered;
  }

  void filter({String? platform, String? period}) {
    if (platform != null) _platform = platform;
    if (period != null) _period = period;
    notifyListeners();
  }

  Future<void> loadReports() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _rawReports = await _service.getReports();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadSummary() async {
    try {
      _summary = await _service.getSummary();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadRevenue() async {
    try {
      _revenueData = await _service.getRevenueTrends();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadOrders() async {
    try {
      _ordersData = await _service.getOrdersTrends();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadProducts() async {
    try {
      _productData = await _service.getProductsStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadEmployees() async {
    try {
      _employeeData = await _service.getEmployeesStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadDetail(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedReport = await _service.getReportById(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadReports();
    await loadSummary();
    await loadRevenue();
    await loadOrders();
    await loadProducts();
    await loadEmployees();
    if (_selectedReport != null) {
      await loadDetail(_selectedReport!.id);
    }
  }
}
