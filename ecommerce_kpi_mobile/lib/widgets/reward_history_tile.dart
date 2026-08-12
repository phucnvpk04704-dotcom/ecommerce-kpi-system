import 'package:flutter/material.dart';
import '../models/reward.dart';
import 'reward_amount_widget.dart';
import 'reward_status_badge.dart';

class RewardHistoryTile extends StatelessWidget {
  final Reward reward;

  const RewardHistoryTile({
    super.key,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D0308).withAlpha(120) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF330C14).withAlpha(100) : const Color(0xFFF3E6E8),
        ),
      ),
      child: Row(
        children: [
          // Icon decoration
          const Icon(Icons.history_toggle_off_rounded, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          // Employee Name & Reward Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.employeeName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2B0008),
                  ),
                ),
                Text(
                  '${reward.rewardType} (${reward.period})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Reward Amount & Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RewardAmountWidget(
                amount: reward.rewardAmount,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple),
              ),
              const SizedBox(height: 2),
              RewardStatusBadge(status: reward.rewardStatus),
            ],
          ),
        ],
      ),
    );
  }
}
