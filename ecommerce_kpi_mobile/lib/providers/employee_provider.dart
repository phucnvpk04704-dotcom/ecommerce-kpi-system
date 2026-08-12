import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final EmployeeService _service;

  EmployeeProvider({EmployeeService? service})
      : _service = service ?? EmployeeService();

  bool _loading = false;
  bool get loading => _loading;

  List<Employee> _allEmployees = [];
  Employee? _selectedEmployee;
  Employee? get selectedEmployee => _selectedEmployee;

  String _searchKeyword = '';
  String get searchKeyword => _searchKeyword;

  String _departmentFilter = 'All';
  String get departmentFilter => _departmentFilter;

  String _statusFilter = 'All';
  String get statusFilter => _statusFilter;

  String _sortType = 'nameAsc';
  String get sortType => _sortType;

  String? _error;
  String? get error => _error;

  List<Employee> get employees {
    List<Employee> filtered = List.from(_allEmployees);

    if (_searchKeyword.isNotEmpty) {
      final query = _searchKeyword.toLowerCase();
      filtered = filtered.where((emp) {
        return emp.fullName.toLowerCase().contains(query) ||
            emp.employeeCode.toLowerCase().contains(query) ||
            emp.email.toLowerCase().contains(query) ||
            emp.phone.contains(query);
      }).toList();
    }

    if (_departmentFilter != 'All') {
      filtered = filtered.where((emp) => emp.department == _departmentFilter).toList();
    }

    if (_statusFilter != 'All') {
      filtered = filtered.where((emp) => emp.status.toLowerCase() == _statusFilter.toLowerCase()).toList();
    }

    switch (_sortType) {
      case 'nameAsc':
        filtered.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case 'nameDesc':
        filtered.sort((a, b) => b.fullName.compareTo(a.fullName));
        break;
      case 'kpiDesc':
        filtered.sort((a, b) => b.todayKpi.compareTo(a.todayKpi));
        break;
      case 'kpiAsc':
        filtered.sort((a, b) => a.todayKpi.compareTo(b.todayKpi));
        break;
      case 'revenueDesc':
        filtered.sort((a, b) => b.todayRevenue.compareTo(a.todayRevenue));
        break;
    }

    return filtered;
  }

  Future<void> loadEmployees() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _allEmployees = await _service.getEmployees();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadEmployeeById(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedEmployee = await _service.getEmployeeById(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadEmployees();
    if (_selectedEmployee != null) {
      await loadEmployeeById(_selectedEmployee!.id);
    }
  }

  void search(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  void filter({String? department, String? status}) {
    if (department != null) _departmentFilter = department;
    if (status != null) _statusFilter = status;
    notifyListeners();
  }

  void sort(String sortType) {
    _sortType = sortType;
    notifyListeners();
  }

  Future<bool> createEmployee(Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final newEmp = await _service.createEmployee(data);
      _allEmployees.add(newEmp);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEmployee(String id, Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateEmployee(id, data);
      _allEmployees = _allEmployees.map((emp) => emp.id == id ? updated : emp).toList();
      if (_selectedEmployee?.id == id) {
        _selectedEmployee = updated;
      }
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEmployee(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteEmployee(id);
      _allEmployees.removeWhere((emp) => emp.id == id);
      if (_selectedEmployee?.id == id) {
        _selectedEmployee = null;
      }
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> changeStatus(String id, String status) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.changeStatus(id, status);
      _allEmployees = _allEmployees.map((emp) => emp.id == id ? updated : emp).toList();
      if (_selectedEmployee?.id == id) {
        _selectedEmployee = updated;
      }
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
