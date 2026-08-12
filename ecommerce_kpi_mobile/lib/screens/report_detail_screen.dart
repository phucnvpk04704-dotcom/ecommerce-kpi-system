import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/custom_provider.dart';
import '../providers/report_provider.dart';
import '../services/report_service.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;
  final ReportService? service;

  const ReportDetailScreen({
    super.key,
    required this.reportId,
    this.service,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'vi_VN', decimalDigits: 0);

    return ChangeNotifierProvider<ReportProvider>(
      create: (_) => ReportProvider(service: widget.service)..loadDetail(widget.reportId),
      child: Consumer<ReportProvider>(
        builder: (context, provider, child) {
          final r = provider.selectedReport;

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF120005) : const Color(0xFFFDF7F8),
            appBar: AppBar(
              title: const Text('Report Overview'),
              backgroundColor: isDark ? const Color(0xFF1D0308) : const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: RefreshIndicator(
              onRefresh: () => provider.refresh(),
              color: const Color(0xFFFF5722),
              child: provider.loading && r == null
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
                  : provider.error != null
                      ? _buildErrorContent(context, provider)
                      : r == null
                          ? _buildEmptyContent(context)
                          : SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title section
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1D0308) : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.assessment_rounded, size: 48, color: Color(0xFFFF5722)),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                r.title,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? Colors.white : const Color(0xFF2B0008),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Generated on ${_formatDate(r.generatedAt)}',
                                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Financial performance
                                  Text(
                                    'Financial Breakdown',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF2B0008),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildInfoCard(
                                    context,
                                    [
                                      _buildInfoRow(context, 'Total Revenue', currencyFormat.format(r.totalRevenue), color: Colors.purple),
                                      _buildInfoRow(context, 'Average Order Value (AOV)', currencyFormat.format(r.averageOrderValue)),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Order breakdown
                                  Text(
                                    'Order Fulfillment Metrics',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF2B0008),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildInfoCard(
                                    context,
                                    [
                                      _buildInfoRow(context, 'Total Placed Orders', '${r.totalOrders}'),
                                      _buildInfoRow(context, 'Completed Orders', '${r.completedOrders}', color: Colors.green),
                                      _buildInfoRow(context, 'Cancelled Orders', '${r.cancelledOrders}', color: Colors.red),
                                      _buildInfoRow(context, 'Refund / Return Orders', '${r.returnOrders}', color: Colors.orange),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Highlighted details
                                  Text(
                                    'Highlights & Top Statistics',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF2B0008),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildInfoCard(
                                    context,
                                    [
                                      _buildInfoRow(context, 'Top Contributing Employee', r.topEmployee),
                                      _buildInfoRow(context, 'Top Selling Product SKU', r.topProduct),
                                      _buildInfoRow(context, 'Report Period Coverage', r.period),
                                      _buildInfoRow(context, 'Platform Channel Source', r.platform),
                                      _buildInfoRow(context, 'Compilation Status', r.status),
                                    ],
                                  ),
                                ],
                              ),
                            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D0308) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {Color? color}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color ?? (isDark ? Colors.white : const Color(0xFF2B0008)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String rawStr) {
    if (rawStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(rawStr);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      if (rawStr.length >= 10) return rawStr.substring(0, 10);
      return rawStr;
    }
  }

  Widget _buildErrorContent(BuildContext context, ReportProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text('Error loading report info', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(provider.error ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722), foregroundColor: Colors.white),
            onPressed: () => provider.loadDetail(widget.reportId),
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
          Icon(Icons.assignment_late_rounded, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('Report not found'),
        ],
      ),
    );
  }
}
