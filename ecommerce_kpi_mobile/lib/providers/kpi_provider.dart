import 'package:flutter/material.dart';
import '../models/kpi.dart';
import '../services/kpi_service.dart';

class KpiProvider extends ChangeNotifier {
  final KpiService _service;

  KpiProvider({KpiService? service})
      : _service = service ?? KpiService();

  bool _loading = false;
  bool get loading => _loading;

  List<Kpi> _rawKpis = [];
  Kpi? _selectedKpi;
  Kpi? get selectedKpi => _selectedKpi;

  String _selectedPeriod = 'today'; // today, week, month
  String get selectedPeriod => _selectedPeriod;

  String _departmentFilter = 'All';
  String get departmentFilter => _departmentFilter;

  String _searchKeyword = '';
  String get searchKeyword => _searchKeyword;

  String _sortType = 'kpiDesc'; // kpiDesc, kpiAsc, nameAsc, revenueDesc
  String get sortType => _sortType;

  String? _error;
  String? get error => _error;

  List<Kpi> get listKpi {
    List<Kpi> filtered = List.from(_rawKpis);

    if (_searchKeyword.isNotEmpty) {
      final query = _searchKeyword.toLowerCase();
      filtered = filtered.where((item) {
        return item.employeeName.toLowerCase().contains(query) ||
            item.department.toLowerCase().contains(query);
      }).toList();
    }

    if (_departmentFilter != 'All') {
      filtered = filtered.where((item) => item.department == _departmentFilter).toList();
    }

    switch (_sortType) {
      case 'kpiDesc':
        filtered.sort((a, b) => b.totalKpi.compareTo(a.totalKpi));
        break;
      case 'kpiAsc':
        filtered.sort((a, b) => a.totalKpi.compareTo(b.totalKpi));
        break;
      case 'nameAsc':
        filtered.sort((a, b) => a.employeeName.compareTo(b.employeeName));
        break;
      case 'revenueDesc':
        filtered.sort((a, b) => b.todayRevenue.compareTo(a.todayRevenue));
        break;
    }

    return filtered;
  }

  Future<void> loadToday() async {
    _loading = true;
    _error = null;
    _selectedPeriod = 'today';
    notifyListeners();

    try {
      _rawKpis = await _service.getTodayKpi();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadWeek() async {
    _loading = true;
    _error = null;
    _selectedPeriod = 'week';
    notifyListeners();

    try {
      _rawKpis = await _service.getWeekKpi();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMonth() async {
    _loading = true;
    _error = null;
    _selectedPeriod = 'month';
    notifyListeners();

    try {
      _rawKpis = await _service.getMonthKpi();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadEmployee(String employeeId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedKpi = await _service.getEmployeeKpi(employeeId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_selectedPeriod == 'today') {
      await loadToday();
    } else if (_selectedPeriod == 'week') {
      await loadWeek();
    } else {
      await loadMonth();
    }

    if (_selectedKpi != null) {
      await loadEmployee(_selectedKpi!.employeeId);
    }
  }

  void search(String query) {
    _searchKeyword = query;
    notifyListeners();
  }

  void filter(String department) {
    _departmentFilter = department;
    notifyListeners();
  }

  void sort(String sortType) {
    _sortType = sortType;
    notifyListeners();
  }
}
