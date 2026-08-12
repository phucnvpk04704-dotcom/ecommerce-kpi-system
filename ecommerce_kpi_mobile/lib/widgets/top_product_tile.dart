import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TopProductTile extends StatelessWidget {
  final int index;
  final String productName;
  final int quantity;
  final double revenue;

  const TopProductTile({
    super.key,
    required this.index,
    required this.productName,
    required this.quantity,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0);

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
          // Index number
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Name and Units Sold
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2B0008),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$quantity sold',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Total Revenue contribution
          Text(
            currencyFormat.format(revenue),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
        ],
      ),
    );
  }
}
