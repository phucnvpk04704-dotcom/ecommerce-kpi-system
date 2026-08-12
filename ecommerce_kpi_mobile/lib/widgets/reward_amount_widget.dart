import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RewardAmountWidget extends StatelessWidget {
  final double amount;
  final TextStyle? style;

  const RewardAmountWidget({
    super.key,
    required this.amount,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      currencyFormat.format(amount),
      style: style ?? TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? const Color(0xFFCCA5AB) : const Color(0xFF800020),
      ),
    );
  }
}
