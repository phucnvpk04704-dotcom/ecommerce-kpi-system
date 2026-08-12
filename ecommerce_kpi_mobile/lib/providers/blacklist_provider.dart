import 'package:flutter/material.dart';
import '../models/blacklist_customer.dart';
import '../services/blacklist_service.dart';

class BlacklistProvider extends ChangeNotifier {
  final BlacklistService _service;

  BlacklistProvider({BlacklistService? service})
      : _service = service ?? BlacklistService();

  bool _loading = false;
  bool get loading => _loading;

  List<BlacklistCustomer> _rawCustomers = [];
  BlacklistCustomer? _selectedCustomer;
  BlacklistCustomer? get selectedCustomer => _selectedCustomer;

  Map<String, dynamic> _statistics = {
    'total_blacklist': 0,
    'high_risk_count': 0,
    'warning_risk_count': 0,
  };
  Map<String, dynamic> get statistics => _statistics;

  String _searchKeyword = '';
  String get searchKeyword => _searchKeyword;

  String _riskLevel = 'All';
  String get riskLevel => _riskLevel;

  String _platform = 'All';
  String get platform => _platform;

  String _status = 'All';
  String get status => _status;

  String? _error;
  String? get error => _error;

  List<BlacklistCustomer> get customerList {
    List<BlacklistCustomer> filtered = List.from(_rawCustomers);

    if (_searchKeyword.isNotEmpty) {
      final query = _searchKeyword.toLowerCase();
      filtered = filtered.where((item) {
        return item.customerName.toLowerCase().contains(query) ||
            item.phone.contains(query);
      }).toList();
    }

    if (_riskLevel != 'All') {
      filtered = filtered.where((item) => item.riskLevel.toLowerCase() == _riskLevel.toLowerCase()).toList();
    }

    if (_platform != 'All') {
      filtered = filtered.where((item) => item.platform.toLowerCase() == _platform.toLowerCase()).toList();
    }

    if (_status != 'All') {
      filtered = filtered.where((item) => item.status.toLowerCase() == _status.toLowerCase()).toList();
    }

    return filtered;
  }

  Future<void> loadCustomers() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _rawCustomers = await _service.getBlacklist();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomer(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedCustomer = await _service.getCustomerById(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadStatistics() async {
    try {
      _statistics = await _service.getStatistics();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadCustomers();
    await loadStatistics();
    if (_selectedCustomer != null) {
      await loadCustomer(_selectedCustomer!.id);
    }
  }

  void search(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  void filter({String? riskLevel, String? platform, String? status}) {
    if (riskLevel != null) _riskLevel = riskLevel;
    if (platform != null) _platform = platform;
    if (status != null) _status = status;
    notifyListeners();
  }

  Future<bool> createCustomer(Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final newCust = await _service.createCustomer(data);
      _rawCustomers.add(newCust);
      _error = null;
      await loadStatistics();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCustomer(String id, Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateCustomer(id, data);
      _rawCustomers = _rawCustomers.map((c) => c.id == id ? updated : c).toList();
      if (_selectedCustomer?.id == id) {
        _selectedCustomer = updated;
      }
      _error = null;
      await loadStatistics();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> changeStatus(String id, String newStatus) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.changeStatus(id, newStatus);
      _rawCustomers = _rawCustomers.map((c) => c.id == id ? updated : c).toList();
      if (_selectedCustomer?.id == id) {
        _selectedCustomer = updated;
      }
      _error = null;
      await loadStatistics();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCustomer(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteCustomer(id);
      _rawCustomers.removeWhere((c) => c.id == id);
      if (_selectedCustomer?.id == id) {
        _selectedCustomer = null;
      }
      _error = null;
      await loadStatistics();
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
