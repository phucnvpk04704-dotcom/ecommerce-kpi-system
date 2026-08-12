import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/providers.dart';
import '../shared/responsive_layout.dart';
import 'widgets/leaderboard_card.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _searchQuery = '';
  String _selectedDepartment = 'All';

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final theme = Theme.of(context);

    return ResponsiveLayout(
      title: 'Leaderboard',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search text field
            TextField(
              decoration: InputDecoration(
                hintText: 'Search contender by name...',
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

            // Department ChoiceChips
            _buildFiltersRow(theme),
            const SizedBox(height: 16),

            // Ranking list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(leaderboardProvider);
                },
                child: leaderboardAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error loading leaderboard: $err')),
                  data: (ranks) {
                    final List<Map<String, dynamic>> filtered = [];

                    for (int i = 0; i < ranks.length; i++) {
                      final item = ranks[i];
                      final name = (item['name'] as String).toLowerCase();
                      final dept = item['department'] ?? '';

                      final matchesSearch = name.contains(_searchQuery);
                      final matchesDept = _selectedDepartment == 'All' || dept == _selectedDepartment;

                      if (matchesSearch && matchesDept) {
                        filtered.add({
                          ...item,
                          'rank': i + 1, // Set index position dynamically based on backend sorted ranking
                        });
                      }
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events_outlined, size: 54, color: theme.brightness == Brightness.dark ? const Color(0xFF6B4B50) : Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No contenders match active criteria.',
                              style: TextStyle(
                                color: theme.brightness == Brightness.dark ? const Color(0xFFCCA5AB) : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final bool showPodium = _searchQuery.isEmpty && _selectedDepartment == 'All' && filtered.length >= 3;
                    final topThree = showPodium ? filtered.sublist(0, 3) : <Map<String, dynamic>>[];
                    final remainder = showPodium ? filtered.sublist(3) : filtered;

                    return ListView.builder(
                      itemCount: remainder.length + (showPodium ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (showPodium && index == 0) {
                          return _buildPodium(theme, topThree);
                        }
                        final item = remainder[showPodium ? index - 1 : index];
                        return LeaderboardCard(rankEntry: item);
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

  Widget _buildFiltersRow(ThemeData theme) {
    final List<String> depts = ['All', 'Marketing', 'Sales', 'Customer Support', 'Logistics'];
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

  Widget _buildPodium(ThemeData theme, List<Map<String, dynamic>> topThree) {
    if (topThree.isEmpty) return const SizedBox();
    
    Map<String, dynamic>? second = topThree.length > 1 ? topThree[1] : null;
    Map<String, dynamic> first = topThree[0];
    Map<String, dynamic>? third = topThree.length > 2 ? topThree[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (second != null)
            Expanded(
              child: _buildPodiumSpot(theme, second, 2, 110, const Color(0xFFC0C0C0)),
            )
          else
            const Spacer(),
            
          const SizedBox(width: 8),
          
          // 1st Place (Center, tallest)
          Expanded(
            child: _buildPodiumSpot(theme, first, 1, 135, Colors.amber),
          ),
          
          const SizedBox(width: 8),

          // 3rd Place
          if (third != null)
            Expanded(
              child: _buildPodiumSpot(theme, third, 3, 95, const Color(0xFFCD7F32)),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPodiumSpot(ThemeData theme, Map<String, dynamic> emp, int rank, double height, Color color) {
    final String name = emp['name'] ?? 'Employee';
    final String initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'E';
    final double kpi = (emp['kpi'] as num?)?.toDouble() ?? 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 32 : 26,
              backgroundColor: color.withValues(alpha: 0.25),
              child: CircleAvatar(
                radius: rank == 1 ? 28 : 23,
                backgroundColor: theme.colorScheme.surface,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rank == 1 ? 18 : 15,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            if (rank == 1)
              const Positioned(
                top: -10,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.18),
                color.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: color,
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name.split(' ').first,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${kpi.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
