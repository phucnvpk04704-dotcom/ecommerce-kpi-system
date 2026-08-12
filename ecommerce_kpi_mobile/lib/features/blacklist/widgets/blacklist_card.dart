import 'package:flutter/material.dart';

class BlacklistCard extends StatelessWidget {
  final Map<String, dynamic> customer;
  final double cancellationRate;
  final List<String> fraudIndicators;

  const BlacklistCard({
    super.key,
    required this.customer,
    required this.cancellationRate,
    required this.fraudIndicators,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final risk = customer['risk'] ?? 'Low';

    Color riskColor = Colors.green;
    if (risk == 'High') {
      riskColor = theme.colorScheme.error;
    } else if (risk == 'Medium') {
      riskColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    customer['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: riskColor.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Text(
                    '$risk Risk',
                    style: TextStyle(
                      color: riskColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              customer['reason'] ?? '',
              style: TextStyle(
                fontSize: 12,
                color: theme.brightness == Brightness.dark ? const Color(0xFFCCA5AB) : const Color(0xFF6E5256),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Cancel Rate: ${cancellationRate.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'Added: ${customer['date']}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8C7174)),
                ),
              ],
            ),
            if (fraudIndicators.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Fraud Indicators:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8C7174)),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: fraudIndicators.map((indicator) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark 
                          ? const Color(0xFF2C0A10) 
                          : const Color(0xFFFFF2F4),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark 
                            ? const Color(0xFF3D0E18) 
                            : const Color(0xFFEAD5D8),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      indicator,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark 
                            ? const Color(0xFFCCA5AB) 
                            : const Color(0xFF800020),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
