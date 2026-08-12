import '../core/network/api_client.dart';
import '../data/services/secure_storage_service.dart';
import '../models/reward.dart';

class RewardService {
  final ApiClient apiClient;

  RewardService({ApiClient? client})
      : apiClient = client ?? ApiClient(storageService: SecureStorageService());

  Future<List<Reward>> getRewards() async {
    try {
      final response = await apiClient.get('/rewards');
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => Reward.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Reward> getRewardById(String id) async {
    try {
      final response = await apiClient.get('/rewards/$id');
      return Reward.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSummary() async {
    try {
      final response = await apiClient.get('/rewards/summary');
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      try {
        final list = await getRewards();
        final totalAmount = list.where((r) => r.rewardStatus.toLowerCase() == 'approved').fold(0.0, (double sum, r) => sum + r.rewardAmount);
        final countRewarded = list.where((r) => r.rewardStatus.toLowerCase() == 'approved').map((r) => r.employeeId).toSet().length;
        return {
          'total_reward_amount': totalAmount,
          'employees_rewarded': countRewarded,
        };
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<List<Reward>> getHistory() async {
    try {
      final response = await apiClient.get('/rewards/history');
      final list = response.data as List<dynamic>? ?? [];
      return list.map((item) => Reward.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      try {
        final list = await getRewards();
        return list.where((r) => r.rewardStatus.toLowerCase() != 'pending').toList();
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<Reward> createReward(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post('/rewards', data: data);
      return Reward.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Reward> updateReward(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put('/rewards/$id', data: data);
      return Reward.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Reward> approveReward(String id) async {
    try {
      final response = await apiClient.dio.patch('/rewards/$id/approve');
      return Reward.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      try {
        final response = await apiClient.put('/rewards/$id', data: {'status': 'Approved', 'reward_status': 'Approved'});
        return Reward.fromJson(response.data as Map<String, dynamic>);
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<Reward> rejectReward(String id) async {
    try {
      final response = await apiClient.dio.patch('/rewards/$id/reject');
      return Reward.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      try {
        final response = await apiClient.put('/rewards/$id', data: {'status': 'Rejected', 'reward_status': 'Rejected'});
        return Reward.fromJson(response.data as Map<String, dynamic>);
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<void> deleteReward(String id) async {
    try {
      await apiClient.delete('/rewards/$id');
    } catch (e) {
      rethrow;
    }
  }
}
