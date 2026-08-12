import 'package:flutter/material.dart';

class ReportFilterBar extends StatelessWidget {
  final String selectedPlatform;
  final String selectedPeriod;
  final ValueChanged<String> onPlatformChanged;
  final ValueChanged<String> onPeriodChanged;

  const ReportFilterBar({
    super.key,
    required this.selectedPlatform,
    required this.selectedPeriod,
    required this.onPlatformChanged,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<String> platforms = ['All', 'Shopee', 'Lazada', 'TikTok'];
    final List<String> periods = ['All', 'Daily', 'Weekly', 'Monthly'];

    return Row(
      children: [
        // Platform Dropdown
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1D0308) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedPlatform,
                isExpanded: true,
                items: platforms.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text('Platform: $p', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    onPlatformChanged(val);
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Period Dropdown
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1D0308) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedPeriod,
                isExpanded: true,
                items: periods.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text('Period: $p', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    onPeriodChanged(val);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
