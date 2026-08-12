import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/network/providers.dart';
import '../shared/responsive_layout.dart';

// Provider to fetch single employee details
final employeeDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/employees/$id');
  return response.data as Map<String, dynamic>;
});

// Provider to fetch employee KPI history
final employeeKpiHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, id) async {
  final client = ref.watch(apiClientProvider);
  final end = DateTime.now();
  final start = end.subtract(const Duration(days: 30));
  final response = await client.get(
    '/kpi/history/employee/$id',
    queryParameters: {
      'start_date': start.toIso8601String(),
      'end_date': end.toIso8601String(),
    },
  );
  final list = response.data as List<dynamic>? ?? [];
  return list.map((item) => item as Map<String, dynamic>).toList();
});

class EmployeeDetailScreen extends ConsumerWidget {
  final String employeeId;

  const EmployeeDetailScreen({
    super.key,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeDetailProvider(employeeId));
    final historyAsync = ref.watch(employeeKpiHistoryProvider(employeeId));
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0);

    return ResponsiveLayout(
      title: 'Employee Details',
      child: employeeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (emp) {
          final String name = emp['full_name'] ?? emp['name'] ?? 'Employee';
          final String code = emp['employee_code'] ?? 'N/A';
          final String email = emp['email'] ?? 'N/A';
          final String dept = emp['department'] ?? 'Operations';
          final String roleStr = emp['role'] ?? 'Employee';
          final String status = emp['status'] ?? 'Active';
          final double sales = (emp['sales'] as num?)?.toDouble() ?? 0.0;
          final double kpi = (emp['kpi'] as num?)?.toDouble() ?? 0.0;
          final bool isOnline = status == 'Active';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                _buildProfileHeader(theme, name, code, dept, roleStr, isOnline),
                const SizedBox(height: 24),

                // Performance Section
                _buildSectionTitle(theme, 'Key Metrics'),
                const SizedBox(height: 12),
                _buildMetricsGrid(theme, kpi, sales, email, currencyFormat),
                const SizedBox(height: 28),

                // Performance Chart / History
                _buildSectionTitle(theme, 'Last 30 Days KPI Logs'),
                const SizedBox(height: 12),
                _buildHistoryList(theme, historyAsync),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    ThemeData theme,
    String name,
    String code,
    String department,
    String role,
    bool isOnline,
  ) {
    final String initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'E';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Hero(
              tag: 'avatar_$employeeId',
              child: CircleAvatar(
                radius: 36,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isOnline ? Colors.green : Colors.grey).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isOnline ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isOnline ? Colors.green : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$role | $department',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.brightness == Brightness.dark ? const Color(0xFFCCA5AB) : const Color(0xFF6E5256),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Code: $code',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.brightness == Brightness.dark ? const Color(0xFF8C7174) : const Color(0xFFBCA2A5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(ThemeData theme, double kpi, double sales, String email, NumberFormat currencyFormat) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _buildMetricItem(
          theme,
          title: 'Avg KPI Score',
          value: '${kpi.toStringAsFixed(1)}%',
          color: theme.colorScheme.primary,
        ),
        _buildMetricItem(
          theme,
          title: 'Total Sales',
          value: currencyFormat.format(sales),
          color: Colors.green,
        ),
        _buildMetricItem(
          theme,
          title: 'Email Address',
          value: email,
          color: Colors.blue,
          isSmallText: true,
        ),
        _buildMetricItem(
          theme,
          title: 'Access Role',
          value: 'Read Only',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    ThemeData theme, {
    required String title,
    required String value,
    required Color color,
    bool isSmallText = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: theme.brightness == Brightness.dark ? const Color(0xFF8C7174) : const Color(0xFF6E5256),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isSmallText ? 12 : 18,
                fontWeight: FontWeight.bold,
                color: isSmallText ? null : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(ThemeData theme, AsyncValue<List<Map<String, dynamic>>> historyAsync) {
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading history: $err')),
      data: (logs) {
        if (logs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: Text('No historical KPI logs found.')),
            ),
          );
        }

        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            separatorBuilder: (context, idx) => Divider(
              color: theme.brightness == Brightness.dark ? const Color(0xFF2C0A10) : const Color(0xFFF3E6E8),
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, idx) {
              final log = logs[idx];
              final double score = (log['total_kpi_score'] as num?)?.toDouble() ?? 0.0;
              final String rawDate = log['date'] ?? '';
              String dateStr = rawDate;
              try {
                if (rawDate.isNotEmpty) {
                  final parsed = DateTime.parse(rawDate);
                  dateStr = DateFormat('dd/MM/yyyy').format(parsed);
                }
              } catch (_) {}

              final String classification = log['classification'] ?? 'Good';

              Color classColor = Colors.green;
              if (classification.toUpperCase().contains('FAIL')) {
                classColor = Colors.red;
              } else if (classification.toUpperCase().contains('PASS')) {
                classColor = Colors.amber;
              }

              return ListTile(
                title: Text(
                  'Daily KPI Score',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  dateStr,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: classColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        classification,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: classColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${score.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}
