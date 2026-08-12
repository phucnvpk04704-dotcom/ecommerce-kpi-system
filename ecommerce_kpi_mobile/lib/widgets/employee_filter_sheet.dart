import 'package:flutter/material.dart';

class EmployeeFilterSheet extends StatefulWidget {
  final String currentDepartment;
  final String currentStatus;
  final String currentSort;
  final Function(String department, String status, String sort) onApply;

  const EmployeeFilterSheet({
    super.key,
    required this.currentDepartment,
    required this.currentStatus,
    required this.currentSort,
    required this.onApply,
  });

  @override
  State<EmployeeFilterSheet> createState() => _EmployeeFilterSheetState();
}

class _EmployeeFilterSheetState extends State<EmployeeFilterSheet> {
  late String _selectedDepartment;
  late String _selectedStatus;
  late String _selectedSort;

  final List<String> _departments = [
    'All',
    'Marketing',
    'Sales',
    'Customer Support',
    'Logistics',
    'Development',
    'Operations',
  ];

  final List<String> _statuses = [
    'All',
    'Active',
    'Inactive',
  ];

  final Map<String, String> _sortOptions = {
    'nameAsc': 'Name: A to Z',
    'nameDesc': 'Name: Z to A',
    'kpiDesc': 'KPI: High to Low',
    'kpiAsc': 'KPI: Low to High',
    'revenueDesc': 'Revenue: High to Low',
  };

  @override
  void initState() {
    super.initState();
    _selectedDepartment = widget.currentDepartment;
    _selectedStatus = widget.currentStatus;
    _selectedSort = widget.currentSort;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D0308) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters & Sorting',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2B0008),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDepartment = 'All';
                      _selectedStatus = 'All';
                      _selectedSort = 'nameAsc';
                    });
                  },
                  child: const Text(
                    'Reset All',
                    style: TextStyle(color: Color(0xFFFF5722)),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // 1. Sort Options
            Text(
              'Sort By',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _sortOptions.entries.map((entry) {
                final isSelected = _selectedSort == entry.key;
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFF5722).withAlpha(40),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFFF5722) : (isDark ? Colors.white : Colors.black),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSort = entry.key;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 2. Department
            Text(
              'Department',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _departments.map((dept) {
                final isSelected = _selectedDepartment == dept;
                return ChoiceChip(
                  label: Text(dept),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFF5722).withAlpha(40),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFFF5722) : (isDark ? Colors.white : Colors.black),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDepartment = dept;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 3. Status
            Text(
              'Status',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _statuses.map((status) {
                final isSelected = _selectedStatus == status;
                return ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFF5722).withAlpha(40),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFFF5722) : (isDark ? Colors.white : Colors.black),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Apply Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                widget.onApply(_selectedDepartment, _selectedStatus, _selectedSort);
              },
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
