import 'package:flutter/material.dart';

class KpiFilterBar extends StatefulWidget {
  final String selectedPeriod;
  final String selectedDepartment;
  final String searchKeyword;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onSearchKeywordChanged;

  const KpiFilterBar({
    super.key,
    required this.selectedPeriod,
    required this.selectedDepartment,
    required this.searchKeyword,
    required this.onPeriodChanged,
    required this.onDepartmentChanged,
    required this.onSearchKeywordChanged,
  });

  @override
  State<KpiFilterBar> createState() => _KpiFilterBarState();
}

class _KpiFilterBarState extends State<KpiFilterBar> {
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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchKeyword);
  }

  @override
  void didUpdateWidget(covariant KpiFilterBar oldWidget) {
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
      children: [
        // Search Input
        TextField(
          controller: _searchController,
          onChanged: widget.onSearchKeywordChanged,
          decoration: InputDecoration(
            hintText: 'Search employee name...',
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

        // Period Choices & Department Selector
        Row(
          children: [
            // Period chips
            Expanded(
              child: ToggleButtons(
                isSelected: [
                  widget.selectedPeriod == 'today',
                  widget.selectedPeriod == 'week',
                  widget.selectedPeriod == 'month',
                ],
                onPressed: (index) {
                  if (index == 0) widget.onPeriodChanged('today');
                  if (index == 1) widget.onPeriodChanged('week');
                  if (index == 2) widget.onPeriodChanged('month');
                },
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                fillColor: const Color(0xFFFF5722),
                color: isDark ? Colors.white : Colors.black,
                constraints: const BoxConstraints(minHeight: 40, minWidth: 60),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Week', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Month', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Department Dropdown
            Container(
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
                  items: _departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept,
                      child: Text(dept, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
          ],
        ),
      ],
    );
  }
}
