import 'package:flutter/material.dart';

class BlacklistFilterBar extends StatefulWidget {
  final String riskLevel;
  final String platform;
  final String status;
  final String searchKeyword;
  final ValueChanged<String> onRiskLevelChanged;
  final ValueChanged<String> onPlatformChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSearchKeywordChanged;

  const BlacklistFilterBar({
    super.key,
    required this.riskLevel,
    required this.platform,
    required this.status,
    required this.searchKeyword,
    required this.onRiskLevelChanged,
    required this.onPlatformChanged,
    required this.onStatusChanged,
    required this.onSearchKeywordChanged,
  });

  @override
  State<BlacklistFilterBar> createState() => _BlacklistFilterBarState();
}

class _BlacklistFilterBarState extends State<BlacklistFilterBar> {
  late TextEditingController _searchController;
  final List<String> _platforms = ['All', 'Shopee', 'Lazada', 'TikTok'];
  final List<String> _riskLevels = ['All', 'High', 'Warning', 'Safe'];
  final List<String> _statuses = ['All', 'Active', 'Resolved'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchKeyword);
  }

  @override
  void didUpdateWidget(covariant BlacklistFilterBar oldWidget) {
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
            hintText: 'Search customer name or phone...',
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

        // Dropdowns row
        Row(
          children: [
            // Risk dropdown
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
                    value: widget.riskLevel,
                    isExpanded: true,
                    items: _riskLevels.map((rl) {
                      return DropdownMenuItem(
                        value: rl,
                        child: Text('Risk: $rl', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        widget.onRiskLevelChanged(val);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Platform dropdown
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
                    value: widget.platform,
                    isExpanded: true,
                    items: _platforms.map((pf) {
                      return DropdownMenuItem(
                        value: pf,
                        child: Text('Platform: $pf', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        widget.onPlatformChanged(val);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Status choices Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _statuses.map((status) {
              final isSelected = widget.status == status;
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
