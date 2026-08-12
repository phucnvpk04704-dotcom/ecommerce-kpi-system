import 'package:flutter/material.dart';
import '../models/reward.dart';
import '../services/reward_service.dart';

class RewardProvider extends ChangeNotifier {
  final RewardService _service;

  RewardProvider({RewardService? service})
      : _service = service ?? RewardService();

  bool _loading = false;
  bool get loading => _loading;

  List<Reward> _rawRewards = [];
  Reward? _selectedReward;
  Reward? get selectedReward => _selectedReward;

  Map<String, dynamic> _summary = {
    'total_reward_amount': 0.0,
    'employees_rewarded': 0,
  };
  Map<String, dynamic> get summary => _summary;

  String _period = 'All';
  String get period => _period;

  String _status = 'All';
  String get status => _status;

  String _searchKeyword = '';
  String get searchKeyword => _searchKeyword;

  String _department = 'All';
  String get department => _department;

  String? _error;
  String? get error => _error;

  List<Reward> get rewardList {
    List<Reward> filtered = List.from(_rawRewards);

    if (_searchKeyword.isNotEmpty) {
      final query = _searchKeyword.toLowerCase();
      filtered = filtered.where((item) {
        return item.employeeName.toLowerCase().contains(query) ||
            item.rewardType.toLowerCase().contains(query);
      }).toList();
    }

    if (_period != 'All') {
      filtered = filtered.where((item) => item.period.toLowerCase() == _period.toLowerCase()).toList();
    }

    if (_status != 'All') {
      filtered = filtered.where((item) => item.rewardStatus.toLowerCase() == _status.toLowerCase()).toList();
    }

    if (_department != 'All') {
      filtered = filtered.where((item) => item.department.toLowerCase() == _department.toLowerCase()).toList();
    }

    return filtered;
  }

  Future<void> loadRewards() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _rawRewards = await _service.getRewards();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _rawRewards = await _service.getHistory();
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

  Future<void> loadReward(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedReward = await _service.getRewardById(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadRewards();
    await loadSummary();
    if (_selectedReward != null) {
      await loadReward(_selectedReward!.id);
    }
  }

  void search(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  void filter({String? period, String? status, String? department}) {
    if (period != null) _period = period;
    if (status != null) _status = status;
    if (department != null) _department = department;
    notifyListeners();
  }

  Future<bool> createReward(Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final newReward = await _service.createReward(data);
      _rawRewards.add(newReward);
      _error = null;
      await loadSummary();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateReward(String id, Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.updateReward(id, data);
      _rawRewards = _rawRewards.map((r) => r.id == id ? updated : r).toList();
      if (_selectedReward?.id == id) {
        _selectedReward = updated;
      }
      _error = null;
      await loadSummary();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> approveReward(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.approveReward(id);
      _rawRewards = _rawRewards.map((r) => r.id == id ? updated : r).toList();
      if (_selectedReward?.id == id) {
        _selectedReward = updated;
      }
      _error = null;
      await loadSummary();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectReward(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _service.rejectReward(id);
      _rawRewards = _rawRewards.map((r) => r.id == id ? updated : r).toList();
      if (_selectedReward?.id == id) {
        _selectedReward = updated;
      }
      _error = null;
      await loadSummary();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReward(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteReward(id);
      _rawRewards.removeWhere((r) => r.id == id);
      if (_selectedReward?.id == id) {
        _selectedReward = null;
      }
      _error = null;
      await loadSummary();
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
