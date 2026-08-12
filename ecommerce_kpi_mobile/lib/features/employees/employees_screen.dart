import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/providers.dart';
import '../shared/responsive_layout.dart';
import 'widgets/employee_card.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  final String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesKPIProvider);
    final theme = Theme.of(context);

    return ResponsiveLayout(
      title: 'Team Performance',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Summary row
            employeesAsync.when(
              loading: () => const SizedBox(height: 50, child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => const SizedBox(),
              data: (employees) {
                final total = employees.length;
                int active = employees.where((e) => e['status'] == 'Active').length;
                double sum = 0.0;
                for (final e in employees) {
                  sum += e['kpi'] ?? 0.0;
                }
                final avgKpi = total > 0 ? (sum / total) : 0.0;

                return Row(
                  children: [
                    _buildSummaryMiniCard(theme, 'Total', '$total'),
                    const SizedBox(width: 10),
                    _buildSummaryMiniCard(theme, 'Active', '$active'),
                    const SizedBox(width: 10),
                    _buildSummaryMiniCard(theme, 'Avg KPI', '${avgKpi.toStringAsFixed(1)}%'),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Search text field
            TextField(
              decoration: InputDecoration(
                hintText: 'Search employees by name...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 12),

            // Filter horizontal list
            _buildFiltersRow(theme),
            const SizedBox(height: 16),

            // List of employees
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(employeesKPIProvider);
                },
                child: employeesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error loading directory: $err')),
                  data: (employees) {
                    final filtered = employees.where((emp) {
                      final name = emp['name']?.toString().toLowerCase() ?? '';
                      final dept = emp['department'] ?? '';
                      final status = emp['status'] ?? 'Active';

                      final matchesSearch = name.contains(_searchQuery);
                      final matchesDept = _selectedDepartment == 'All' || dept == _selectedDepartment;
                      final matchesStatus = _selectedStatus == 'All' || status == _selectedStatus;

                      return matchesSearch && matchesDept && matchesStatus;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 54, color: theme.brightness == Brightness.dark ? const Color(0xFF6B4B50) : Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No employees match parameters.',
                              style: TextStyle(
                                color: theme.brightness == Brightness.dark ? const Color(0xFFCCA5AB) : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, idx) {
                        final emp = filtered[idx];
                        return EmployeeCard(
                          employee: emp,
                          status: emp['status'] ?? 'Active',
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMiniCard(ThemeData theme, String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.brightness == Brightness.dark ? const Color(0xFF8C7174) : const Color(0xFF6E5256),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersRow(ThemeData theme) {
    final List<String> depts = ['All', 'Marketing', 'Sales', 'Customer Support', 'Logistics', 'Development'];
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: depts.length,
        itemBuilder: (context, index) {
          final dept = depts[index];
          final bool isSelected = _selectedDepartment == dept;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                dept,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : (theme.brightness == Brightness.dark ? const Color(0xFFCCA5AB) : const Color(0xFF6E5256)),
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedDepartment = dept;
                });
              },
              selectedColor: theme.colorScheme.primaryContainer,
              backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF1D0308) : Colors.white,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : (theme.brightness == Brightness.dark ? const Color(0xFF3D0E18) : const Color(0xFFEAD5D8)),
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
