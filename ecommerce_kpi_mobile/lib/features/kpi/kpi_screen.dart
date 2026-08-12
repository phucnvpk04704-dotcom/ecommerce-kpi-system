import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/network/providers.dart';
import '../shared/responsive_layout.dart';

// Provider to fetch recent daily KPI logs for the history section
final generalKpiHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final response = await client.get('/kpi?skip=0&limit=30');
    final list = response.data as List<dynamic>? ?? [];
    return list.map((item) => item as Map<String, dynamic>).toList();
  } catch (_) {
    return [];
  }
});

class KpiScreen extends ConsumerWidget {
  const KpiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpiSummaryAsync = ref.watch(kpiSummaryProvider);
    final historyAsync = ref.watch(generalKpiHistoryProvider);
    final theme = Theme.of(context);

    return ResponsiveLayout(
      title: 'Store KPI Performance',
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(kpiSummaryProvider);
          ref.invalidate(generalKpiHistoryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: kpiSummaryAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
              ),
            ),
            data: (kpiData) {
              final double avgKpi = (kpiData['total_kpi_score'] as num?)?.toDouble() ?? 88.5;
              final double ordersScore = (kpiData['orders_score'] as num?)?.toDouble() ?? 0.0;
              final double chatsScore = (kpiData['chats_score'] as num?)?.toDouble() ?? 0.0;
              final double productsScore = (kpiData['products_score'] as num?)?.toDouble() ?? 0.0;
              final double revenueScore = (kpiData['revenue_score'] as num?)?.toDouble() ?? 0.0;
              final double penaltyDeductions = (kpiData['penalty_deductions'] as num?)?.toDouble() ?? 0.0;

              final ordersProgress = ordersScore > 0 ? (ordersScore / 40.0) : 0.0;
              final chatsProgress = chatsScore > 0 ? (chatsScore / 20.0) : 0.0;
              final productsProgress = productsScore > 0 ? (productsScore / 15.0) : 0.0;
              final revenueProgress = revenueScore > 0 ? (revenueScore / 25.0) : 0.0;
              final penaltyProgress = (penaltyDeductions / 100.0).clamp(0.0, 1.0);

              // Constituent metrics breakdown
              final metrics = [
                {
                  'title': 'Order Fulfillment Score',
                  'value': '${(ordersProgress * 100).toStringAsFixed(1)}%',
                  'progress': ordersProgress,
                  'icon': Icons.shopping_bag_outlined,
                  'color': Colors.green.shade600,
                  'desc': 'Percentage of orders processed within 24h limit',
                },
                {
                  'title': 'Customer Chat Response',
                  'value': '${(chatsProgress * 100).toStringAsFixed(1)}%',
                  'progress': chatsProgress,
                  'icon': Icons.chat_bubble_outline,
                  'color': Colors.blue.shade600,
                  'desc': 'Average response time < 5 minutes',
                },
                {
                  'title': 'Product Quality & Accuracy',
                  'value': '${(productsProgress * 100).toStringAsFixed(1)}%',
                  'progress': productsProgress,
                  'icon': Icons.check_circle_outline,
                  'color': Colors.teal.shade600,
                  'desc': 'No incorrect or damaged product complaints',
                },
                {
                  'title': 'Revenue Target Achievement',
                  'value': '${(revenueProgress * 100).toStringAsFixed(1)}%',
                  'progress': revenueProgress,
                  'icon': Icons.monetization_on_outlined,
                  'color': Colors.amber.shade700,
                  'desc': 'Achieved revenue vs monthly target',
                },
                {
                  'title': 'Penalty Point Deductions',
                  'value': '-${penaltyDeductions.toStringAsFixed(1)} pts',
                  'progress': penaltyProgress,
                  'icon': Icons.warning_amber_rounded,
                  'color': theme.colorScheme.error,
                  'desc': 'Fines for delayed customer complaints resolution',
                },
              ];

              // Determine performance level
              String performanceLevel = 'GOOD';
              Color levelColor = Colors.green;
              if (avgKpi >= 90.0) {
                performanceLevel = 'EXCELLENT';
                levelColor = const Color(0xFF34D399);
              } else if (avgKpi >= 80.0) {
                performanceLevel = 'GOOD';
                levelColor = Colors.teal.shade400;
              } else if (avgKpi >= 65.0) {
                performanceLevel = 'FAIR';
                levelColor = Colors.amber.shade400;
              } else if (avgKpi >= 50.0) {
                performanceLevel = 'PASS';
                levelColor = Colors.orange.shade400;
              } else {
                performanceLevel = 'FAILED';
                levelColor = theme.colorScheme.error;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circular KPI Gauge Card
                  _buildGaugeCard(theme, avgKpi, performanceLevel, levelColor),
                  const SizedBox(height: 24),

                  // Section Title
                  _buildSectionHeader(theme, 'Operational KPI Breakdown'),
                  const SizedBox(height: 14),

                  // Breakdown Cards list
                  ...metrics.map((metric) {
                    final bool isPenalty = metric['title'].toString().contains('Penalty');
                    final progressVal = metric['progress'] as double;
                    final activeColor = metric['color'] as Color;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: activeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                metric['icon'] as IconData,
                                color: activeColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          metric['title'] as String,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        metric['value'] as String,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isPenalty ? theme.colorScheme.error : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    metric['desc'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.brightness == Brightness.dark ? const Color(0xFF8C7174) : const Color(0xFFBCA2A5),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.0, end: progressVal),
                                    duration: const Duration(milliseconds: 1000),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, animValue, child) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: animValue,
                                          minHeight: 6,
                                          backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF2C0A10) : const Color(0xFFFAF0F1),
                                          valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Section Title: History logs
                  _buildSectionHeader(theme, 'Store Performance Log History'),
                  const SizedBox(height: 14),
                  _buildHistoryList(theme, historyAsync),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGaugeCard(ThemeData theme, double score, String label, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 20.0),
        child: Center(
          child: Column(
            children: [
              const Text(
                'SYSTEM PERFORMANCE INDEX',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Color(0xFFCCA5AB),
                ),
              ),
              const SizedBox(height: 28),

              // Custom speed-arc gauge painter
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: score / 100.0),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeInOutCubic,
                builder: (context, animValue, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 170,
                        height: 170,
                        child: CustomPaint(
                          painter: CircularGaugePainter(
                            value: animValue,
                            activeColor: theme.colorScheme.primary,
                            inactiveColor: theme.brightness == Brightness.dark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(animValue * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Averaged across all registered system operations logs',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8C7174),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(ThemeData theme, AsyncValue<List<Map<String, dynamic>>> historyAsync) {
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading KPI history: $err')),
      data: (logs) {
        if (logs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: Text('No performance log history found.')),
            ),
          );
        }

        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            separatorBuilder: (context, idx) => Divider(
              color: theme.brightness == Brightness.dark ? const Color(0xFF2C0A10) : const Color(0xFFF3E6E8),
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, idx) {
              final log = logs[idx];
              final double score = (log['total_kpi_score'] as num?)?.toDouble() ?? 0.0;
              final String rawDate = log['date'] ?? '';
              String dateStr = rawDate;
              try {
                if (rawDate.isNotEmpty) {
                  final parsed = DateTime.parse(rawDate);
                  dateStr = DateFormat('dd/MM/yyyy').format(parsed);
                }
              } catch (_) {}

              final String classification = log['classification'] ?? 'Good';

              Color classColor = Colors.green;
              if (classification.toUpperCase().contains('FAIL')) {
                classColor = Colors.red;
              } else if (classification.toUpperCase().contains('PASS')) {
                classColor = Colors.amber;
              }

              return ListTile(
                title: const Text(
                  'Store Performance Index',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                subtitle: Text(
                  dateStr,
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: classColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        classification,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: classColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${score.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 16,
        letterSpacing: -0.2,
      ),
    );
  }
}

// Circular Gauge Custom Painter
class CircularGaugePainter extends CustomPainter {
  final double value; // 0.0 to 1.0
  final Color activeColor;
  final Color inactiveColor;

  CircularGaugePainter({
    required this.value,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 12.0;

    final paintBg = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintActive = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background 270 degree arc starting from 135 degrees (bottom left)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      3.14159 * 0.75, // 135 degrees
      3.14159 * 1.5,  // 270 degrees
      false,
      paintBg,
    );

    // Draw active arc mapping to progress value
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      3.14159 * 0.75,
      3.14159 * 1.5 * value.clamp(0.0, 1.0),
      false,
      paintActive,
    );
  }

  @override
  bool shouldRepaint(covariant CircularGaugePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}


