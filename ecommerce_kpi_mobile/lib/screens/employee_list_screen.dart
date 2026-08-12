import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../providers/custom_provider.dart';
import '../../providers/employee_provider.dart';
import '../../services/employee_service.dart';
import '../../widgets/employee_card.dart';
import '../../widgets/employee_search_bar.dart';
import '../../widgets/employee_filter_sheet.dart';

class EmployeeListScreen extends StatefulWidget {
  final EmployeeService? service;
  const EmployeeListScreen({super.key, this.service});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider<EmployeeProvider>(
      create: (_) => EmployeeProvider(service: widget.service)..loadEmployees(),
      child: Consumer<EmployeeProvider>(
        builder: (context, provider, child) {
          final employeeList = provider.employees;

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF120005) : const Color(0xFFFDF7F8),
            appBar: AppBar(
              title: const Text('Employee Directory'),
              backgroundColor: isDark ? const Color(0xFF1D0308) : const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: RefreshIndicator(
              onRefresh: () => provider.refresh(),
              color: const Color(0xFFFF5722),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search and Filter Bar
                    EmployeeSearchBar(
                      initialValue: provider.searchKeyword,
                      onChanged: (val) => provider.search(val),
                      onFilterTap: () => _showFilterSheet(context, provider),
                    ),
                    const SizedBox(height: 16),
                    // Current filters indicators
                    _buildActiveFilters(context, provider),
                    const SizedBox(height: 8),
                    // Body content
                    Expanded(
                      child: _buildListContent(context, provider, employeeList),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              onPressed: () {
                context.go('/employees/create');
              },
              child: const Icon(Icons.add_rounded),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveFilters(BuildContext context, EmployeeProvider provider) {
    final hasDept = provider.departmentFilter != 'All';
    final hasStatus = provider.statusFilter != 'All';
    final hasSort = provider.sortType != 'nameAsc';

    if (!hasDept && !hasStatus && !hasSort) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (hasDept)
            _buildFilterChip(context, 'Dept: ${provider.departmentFilter}', () {
              provider.filter(department: 'All');
            }),
          if (hasStatus)
            _buildFilterChip(context, 'Status: ${provider.statusFilter}', () {
              provider.filter(status: 'All');
            }),
          if (hasSort)
            _buildFilterChip(context, 'Sorted', () {
              provider.sort('nameAsc');
            }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String text, VoidCallback onDeleted) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(text, style: const TextStyle(fontSize: 11)),
        deleteIcon: const Icon(Icons.close_rounded, size: 14),
        onDeleted: onDeleted,
        backgroundColor: const Color(0xFFFF5722).withAlpha(20),
        side: const BorderSide(color: Color(0xFFFF5722), width: 0.5),
        labelStyle: const TextStyle(color: Color(0xFFFF5722)),
      ),
    );
  }

  Widget _buildListContent(BuildContext context, EmployeeProvider provider, List<dynamic> list) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              'Error loading employees',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722), foregroundColor: Colors.white),
              onPressed: () => provider.loadEmployees(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No employees found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try adjusting your search query or active filter settings.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          // Grid layout for Tablet
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 8,
              childAspectRatio: 2.8,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return EmployeeCard(employee: list[index]);
            },
          );
        } else {
          // Standard ListView for Phone
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              return EmployeeCard(employee: list[index]);
            },
          );
        }
      },
    );
  }

  void _showFilterSheet(BuildContext context, EmployeeProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return EmployeeFilterSheet(
          currentDepartment: provider.departmentFilter,
          currentStatus: provider.statusFilter,
          currentSort: provider.sortType,
          onApply: (dept, stat, sortType) {
            provider.filter(department: dept, status: stat);
            provider.sort(sortType);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
