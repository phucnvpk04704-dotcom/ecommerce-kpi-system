import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/providers.dart';
import '../shared/responsive_layout.dart';
import 'widgets/blacklist_card.dart';

class BlacklistScreen extends ConsumerStatefulWidget {
  const BlacklistScreen({super.key});

  @override
  ConsumerState<BlacklistScreen> createState() => _BlacklistScreenState();
}

class _BlacklistScreenState extends ConsumerState<BlacklistScreen> {
  String _searchQuery = '';
  String _selectedRisk = 'All';

  final List<double> _mockCancelRates = [92.0, 78.0, 45.0, 88.0, 95.0];
  final List<List<String>> _mockIndicators = [
    ['Payment Defaults', 'Chargebacks', 'Multiple IPs'],
    ['Voucher Abuse', 'High Order Frequency'],
    ['Abusive Chat', 'Refund Abuse'],
    ['Fake Credit Card', 'Carding Attempts', 'Proxy IPs'],
    ['Breach of Contract', 'Delivery Refusal'],
  ];

  @override
  Widget build(BuildContext context) {
    final blacklistAsync = ref.watch(blacklistProvider);
    final theme = Theme.of(context);

    return ResponsiveLayout(
      title: 'Risk Blacklist',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search text field
            TextField(
              decoration: InputDecoration(
                hintText: 'Search customer name...',
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

            // Dropdown risk selector
            _buildFiltersRow(theme),
            const SizedBox(height: 16),

            // Blacklist List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(blacklistProvider);
                },
                child: blacklistAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error loading blacklist: $err')),
                  data: (blacklist) {
                    final List<Map<String, dynamic>> filtered = [];

                    for (int i = 0; i < blacklist.length; i++) {
                      final customer = blacklist[i];
                      final risk = customer['risk'] ?? 'Low';
                      final cancel = i < _mockCancelRates.length ? _mockCancelRates[i] : 50.0;
                      final indicators = i < _mockIndicators.length ? _mockIndicators[i] : <String>[];

                      final matchesSearch = (customer['name'] as String).toLowerCase().contains(_searchQuery);
                      final matchesRisk = _selectedRisk == 'All' || risk == _selectedRisk;

                      if (matchesSearch && matchesRisk) {
                        filtered.add({
                          ...customer,
                          'cancel_rate': cancel,
                          'indicators': indicators,
                        });
                      }
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gpp_good_rounded, size: 54, color: theme.brightness == Brightness.dark ? const Color(0xFF6B4B50) : Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No blacklisted customers found.',
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
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final double cancel = item['cancel_rate'] ?? 0.0;
                        final List<String> indicators = item['indicators'] ?? <String>[];

                        return BlacklistCard(
                          customer: item,
                          cancellationRate: cancel,
                          fraudIndicators: indicators,
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

  Widget _buildFiltersRow(ThemeData theme) {
    final List<String> risks = ['All', 'High', 'Medium', 'Low'];

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _selectedRisk,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: 'Risk Level',
              labelStyle: const TextStyle(fontSize: 12),
            ),
            items: risks
                .map((risk) => DropdownMenuItem(
                      value: risk,
                      child: Text('$risk Risk', style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedRisk = val;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
