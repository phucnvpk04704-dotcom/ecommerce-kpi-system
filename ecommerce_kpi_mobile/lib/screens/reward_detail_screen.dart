import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/custom_provider.dart';
import '../providers/reward_provider.dart';
import '../services/reward_service.dart';
import '../widgets/reward_status_badge.dart';
import '../widgets/reward_amount_widget.dart';
import '../widgets/reward_action_buttons.dart';

class RewardDetailScreen extends StatefulWidget {
  final String rewardId;
  final RewardService? service;

  const RewardDetailScreen({
    super.key,
    required this.rewardId,
    this.service,
  });

  @override
  State<RewardDetailScreen> createState() => _RewardDetailScreenState();
}

class _RewardDetailScreenState extends State<RewardDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider<RewardProvider>(
      create: (_) => RewardProvider(service: widget.service)..loadReward(widget.rewardId),
      child: Consumer<RewardProvider>(
        builder: (context, provider, child) {
          final reward = provider.selectedReward;

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF120005) : const Color(0xFFFDF7F8),
            appBar: AppBar(
              title: const Text('Reward Details'),
              backgroundColor: isDark ? const Color(0xFF1D0308) : const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: RefreshIndicator(
              onRefresh: () => provider.refresh(),
              color: const Color(0xFFFF5722),
              child: provider.loading && reward == null
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
                  : provider.error != null
                      ? _buildErrorContent(context, provider)
                      : reward == null
                          ? _buildEmptyContent(context)
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final isTablet = constraints.maxWidth >= 600;

                                final headerCard = Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1D0308) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.emoji_events_rounded,
                                        size: 64,
                                        color: Color(0xFFFF5722),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        reward.employeeName,
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF2B0008),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${reward.department} | ${reward.period}',
                                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                      ),
                                      const SizedBox(height: 12),
                                      RewardStatusBadge(status: reward.rewardStatus),
                                    ],
                                  ),
                                );

                                final infoCard = Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1D0308) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Reward Information',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF2B0008),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildInfoRow(context, Icons.star_rounded, 'KPI score', '${reward.kpiScore.toStringAsFixed(1)}%'),
                                      _buildInfoRow(context, Icons.category_rounded, 'Reward Type', reward.rewardType),
                                      _buildInfoRow(
                                        context,
                                        Icons.monetization_on_rounded,
                                        'Reward Amount',
                                        '',
                                        valueWidget: RewardAmountWidget(
                                          amount: reward.rewardAmount,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purple),
                                        ),
                                      ),
                                      if (reward.approvedBy != null) ...[
                                        _buildInfoRow(context, Icons.person_rounded, 'Approved By', reward.approvedBy!),
                                        _buildInfoRow(context, Icons.calendar_today_rounded, 'Approved At', _formatDate(reward.approvedAt)),
                                      ],
                                    ],
                                  ),
                                );

                                final actions = RewardActionButtons(
                                  status: reward.rewardStatus,
                                  onApprove: () => _approve(context, provider, reward.id),
                                  onReject: () => _reject(context, provider, reward.id),
                                  onEdit: () {
                                    context.go('/reward_edit_screen/${reward.id}');
                                  },
                                  onDelete: () => _confirmDelete(context, provider, reward.id),
                                );

                                if (isTablet) {
                                  return SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              headerCard,
                                              const SizedBox(height: 20),
                                              actions,
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: infoCard,
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        headerCard,
                                        const SizedBox(height: 20),
                                        infoCard,
                                        const SizedBox(height: 24),
                                        actions,
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {Widget? valueWidget}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFFF5722)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 2),
                valueWidget ??
                    Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF2B0008),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? rawStr) {
    if (rawStr == null || rawStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(rawStr);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      if (rawStr.length >= 10) return rawStr.substring(0, 10);
      return rawStr;
    }
  }

  void _approve(BuildContext context, RewardProvider provider, String id) async {
    final success = await provider.approveReward(id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Reward request approved.' : 'Failed to approve request.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _reject(BuildContext context, RewardProvider provider, String id) async {
    final success = await provider.rejectReward(id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Reward request rejected.' : 'Failed to reject request.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, RewardProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Reward'),
          content: const Text('Are you sure you want to delete this reward recommendation?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await provider.deleteReward(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Reward suggestion deleted.' : 'Failed to delete suggestion.'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                  if (success) {
                    context.go('/reward_screen');
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorContent(BuildContext context, RewardProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text('Error loading reward profile', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(provider.error ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722), foregroundColor: Colors.white),
            onPressed: () => provider.loadReward(widget.rewardId),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('Reward details not found'),
        ],
      ),
    );
  }
}
