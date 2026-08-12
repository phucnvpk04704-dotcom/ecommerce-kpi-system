import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/blacklist_customer.dart';
import 'risk_badge.dart';

class CustomerCard extends StatelessWidget {
  final BlacklistCustomer customer;

  const CustomerCard({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D0308) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(51) : const Color(0xFF800020).withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.go('/blacklist_detail_screen/${customer.id}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Platform or profile indicator icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.gavel_rounded,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Detailed info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              customer.customerName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF2B0008),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          RiskBadge(riskLevel: customer.riskLevel),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phone: ${customer.phone} | Platform: ${customer.platform}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? const Color(0xFFCCA5AB) : const Color(0xFF8C7174),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildCountChip(Colors.orange, 'Cancel: ${customer.cancelCount}'),
                          _buildCountChip(Colors.purple, 'Return: ${customer.returnCount}'),
                          _buildCountChip(Colors.red, 'Complaint: ${customer.complaintCount}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountChip(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
