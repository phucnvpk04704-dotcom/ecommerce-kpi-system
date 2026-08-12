import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeInformation extends StatelessWidget {
  final Employee employee;

  const EmployeeInformation({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16.0),
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
            'Information Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2B0008),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(context, Icons.badge_rounded, 'Employee Code', employee.employeeCode),
          _buildInfoRow(context, Icons.email_rounded, 'Email Address', employee.email),
          _buildInfoRow(context, Icons.phone_rounded, 'Phone Number', employee.phone),
          _buildInfoRow(context, Icons.work_rounded, 'Role Position', employee.role),
          _buildInfoRow(context, Icons.business_rounded, 'Department', employee.department),
          _buildInfoRow(context, Icons.storefront_rounded, 'Marketplace Platform', employee.platform),
          if (employee.createdAt != null)
            _buildInfoRow(context, Icons.calendar_today_rounded, 'Joined Date', _formatDate(employee.createdAt)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFFFF5722)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'N/A' : value,
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
      if (rawStr.length >= 10) {
        return rawStr.substring(0, 10);
      }
      return rawStr;
    }
  }
}
