import 'package:flutter/material.dart';
import '../models/blacklist_customer.dart';

class CustomerHistoryTile extends StatelessWidget {
  final BlacklistCustomer customer;

  const CustomerHistoryTile({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D0308).withAlpha(120) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF330C14).withAlpha(100) : const Color(0xFFF3E6E8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                'Incident Records',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF2B0008),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildItem(context, 'Cancellations', '${customer.cancelCount} orders', Colors.orange),
          _buildItem(context, 'Refund / Returns', '${customer.returnCount} orders', Colors.purple),
          _buildItem(context, 'Complaints Issued', '${customer.complaintCount} tickets', Colors.red),
          const Divider(height: 16),
          _buildDateItem(context, 'Last Order Date', customer.lastOrderDate),
          _buildDateItem(context, 'Last Violation Date', customer.lastViolationDate),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String label, String value, Color indicatorColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: indicatorColor, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDateItem(BuildContext context, String label, String? dateStr) {
    final displayDate = (dateStr == null || dateStr.isEmpty) ? 'No record' : dateStr;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayDate,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
