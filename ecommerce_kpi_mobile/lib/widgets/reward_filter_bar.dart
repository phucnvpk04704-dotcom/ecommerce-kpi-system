import 'package:flutter/material.dart';

class RewardFilterBar extends StatefulWidget {
  final String selectedPeriod;
  final String selectedStatus;
  final String selectedDepartment;
  final String searchKeyword;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onSearchKeywordChanged;

  const RewardFilterBar({
    super.key,
    required this.selectedPeriod,
    required this.selectedStatus,
    required this.selectedDepartment,
    required this.searchKeyword,
    required this.onPeriodChanged,
    required this.onStatusChanged,
    required this.onDepartmentChanged,
    required this.onSearchKeywordChanged,
  });

  @override
  State<RewardFilterBar> createState() => _RewardFilterBarState();
}

class _RewardFilterBarState extends State<RewardFilterBar> {
  late TextEditingController _searchController;
  final List<String> _departments = [
    'All',
    'Marketing',
    'Sales',
    'Customer Support',
    'Logistics',
    'Development',
    'Operations',
  ];

  final List<String> _periods = ['All', 'Monthly', 'Weekly'];
  final List<String> _statuses = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchKeyword);
  }

  @override
  void didUpdateWidget(covariant RewardFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchKeyword != _searchController.text) {
      _searchController.text = widget.searchKeyword;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input
        TextField(
          controller: _searchController,
          onChanged: widget.onSearchKeywordChanged,
          decoration: InputDecoration(
            hintText: 'Search employee or reward type...',
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFF5722)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      widget.onSearchKeywordChanged('');
                    },
                  )
                : null,
            filled: true,
            fillColor: isDark ? const Color(0xFF1D0308) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFFF5722), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Period & Department Row
        Row(
          children: [
            // Period Choice
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
                    value: widget.selectedPeriod,
                    isExpanded: true,
                    items: _periods.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text('Period: $p', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        widget.onPeriodChanged(val);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Department Choice
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
                    value: widget.selectedDepartment,
                    isExpanded: true,
                    items: _departments.map((dept) {
                      return DropdownMenuItem(
                        value: dept,
                        child: Text(dept, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        widget.onDepartmentChanged(val);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Status Choice chips row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _statuses.map((status) {
              final isSelected = widget.selectedStatus == status;
              return Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(status, style: const TextStyle(fontSize: 11)),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFF5722).withAlpha(40),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFFF5722) : (isDark ? Colors.white : Colors.black),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      widget.onStatusChanged(status);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
