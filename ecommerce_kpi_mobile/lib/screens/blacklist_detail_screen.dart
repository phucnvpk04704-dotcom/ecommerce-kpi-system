import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/custom_provider.dart';
import '../providers/blacklist_provider.dart';
import '../services/blacklist_service.dart';
import '../widgets/risk_badge.dart';
import '../widgets/customer_history_tile.dart';
import '../widgets/customer_action_buttons.dart';

class BlacklistDetailScreen extends StatefulWidget {
  final String customerId;
  final BlacklistService? service;

  const BlacklistDetailScreen({
    super.key,
    required this.customerId,
    this.service,
  });

  @override
  State<BlacklistDetailScreen> createState() => _BlacklistDetailScreenState();
}

class _BlacklistDetailScreenState extends State<BlacklistDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider<BlacklistProvider>(
      create: (_) => BlacklistProvider(service: widget.service)..loadCustomer(widget.customerId),
      child: Consumer<BlacklistProvider>(
        builder: (context, provider, child) {
          final customer = provider.selectedCustomer;

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF120005) : const Color(0xFFFDF7F8),
            appBar: AppBar(
              title: const Text('Blacklist Details'),
              backgroundColor: isDark ? const Color(0xFF1D0308) : const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: RefreshIndicator(
              onRefresh: () => provider.refresh(),
              color: const Color(0xFFFF5722),
              child: provider.loading && customer == null
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
                  : provider.error != null
                      ? _buildErrorContent(context, provider)
                      : customer == null
                          ? _buildEmptyContent(context)
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final isTablet = constraints.maxWidth >= 600;

                                final headerCard = Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1D0308) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.person_outline_rounded,
                                        size: 64,
                                        color: Colors.redAccent,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        customer.customerName,
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF2B0008),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Phone: ${customer.phone} | Platform: ${customer.platform}',
                                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          RiskBadge(riskLevel: customer.riskLevel),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: customer.status.toLowerCase() == 'active'
                                                  ? Colors.red.withAlpha(20)
                                                  : Colors.green.withAlpha(20),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              customer.status,
                                              style: TextStyle(
                                                color: customer.status.toLowerCase() == 'active' ? Colors.red : Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );

                                final noteCard = Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
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
                                        'Admin Incident Note',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF2B0008),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        customer.note.isEmpty ? 'No notes added.' : customer.note,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: isDark ? Colors.white70 : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                final historyWidget = CustomerHistoryTile(customer: customer);

                                final actions = CustomerActionButtons(
                                  status: customer.status,
                                  onToggleStatus: () => _toggleStatus(context, provider, customer.id, customer.status),
                                  onEdit: () {
                                    context.go('/blacklist_edit_screen/${customer.id}');
                                  },
                                  onDelete: () => _confirmDelete(context, provider, customer.id),
                                );

                                if (isTablet) {
                                  return SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              headerCard,
                                              const SizedBox(height: 16),
                                              actions,
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              historyWidget,
                                              const SizedBox(height: 16),
                                              noteCard,
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        headerCard,
                                        const SizedBox(height: 16),
                                        historyWidget,
                                        const SizedBox(height: 16),
                                        noteCard,
                                        const SizedBox(height: 24),
                                        actions,
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
            ),
          );
        },
      ),
    );
  }

  void _toggleStatus(BuildContext context, BlacklistProvider provider, String id, String currentStatus) async {
    final nextStatus = currentStatus.toLowerCase() == 'active' ? 'Resolved' : 'Active';
    final success = await provider.changeStatus(id, nextStatus);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Customer status updated to $nextStatus.' : 'Failed to update customer status.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, BlacklistProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Remove Customer'),
          content: const Text('Are you sure you want to remove this customer from the blacklist?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await provider.deleteCustomer(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Customer removed from blacklist.' : 'Failed to remove customer.'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                  if (success) {
                    context.go('/blacklist_screen');
                  }
                }
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorContent(BuildContext context, BlacklistProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text('Error loading customer details', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(provider.error ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722), foregroundColor: Colors.white),
            onPressed: () => provider.loadCustomer(widget.customerId),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('Blacklist customer profile not found'),
        ],
      ),
    );
  }
}
