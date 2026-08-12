import 'dart:math';
import 'package:flutter/material.dart';
import '../models/kpi.dart';

class KpiChart extends StatefulWidget {
  final List<Kpi> kpiList;

  const KpiChart({
    super.key,
    required this.kpiList,
  });

  @override
  State<KpiChart> createState() => _KpiChartState();
}

class _KpiChartState extends State<KpiChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _activeTab = 0; // 0: Revenue, 1: Orders, 2: Distribution, 3: Top KPI

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant KpiChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16.0),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Performance Trends',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2B0008),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.insights_rounded, color: const Color(0xFFFF5722), size: 20),
            ],
          ),
          const SizedBox(height: 12),

          // Custom sub-tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabItem(0, 'Revenue'),
                const SizedBox(width: 8),
                _buildTabItem(1, 'Orders'),
                const SizedBox(width: 8),
                _buildTabItem(2, 'Brackets'),
                const SizedBox(width: 8),
                _buildTabItem(3, 'Top Performers'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Animated canvas view container
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SizedBox(
                height: 200,
                width: double.infinity,
                child: CustomPaint(
                  painter: _getPainter(_animation.value, isDark),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isActive = _activeTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF5722).withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFFFF5722) : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  CustomPainter _getPainter(double animVal, bool isDark) {
    switch (_activeTab) {
      case 0:
        return _RevenueLinePainter(kpis: widget.kpiList, animationValue: animVal, isDark: isDark);
      case 1:
        return _OrdersBarPainter(kpis: widget.kpiList, animationValue: animVal, isDark: isDark);
      case 2:
        return _KpiDonutPainter(kpis: widget.kpiList, animationValue: animVal, isDark: isDark);
      case 3:
      default:
        return _TopKpiBarPainter(kpis: widget.kpiList, animationValue: animVal, isDark: isDark);
    }
  }
}

class _RevenueLinePainter extends CustomPainter {
  final List<Kpi> kpis;
  final double animationValue;
  final bool isDark;

  _RevenueLinePainter({required this.kpis, required this.animationValue, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (kpis.isEmpty) return;

    final double paddingLeft = 40;
    final double paddingBottom = 20;
    final double paddingTop = 10;
    final double paddingRight = 10;

    final double chartWidth = size.width - paddingLeft - paddingRight;
    final double chartHeight = size.height - paddingTop - paddingBottom;

    // Filter limits
    final maxRevenue = kpis.map((k) => k.todayRevenue).reduce(max);
    final double maxValAdjusted = maxRevenue == 0 ? 1000000 : maxRevenue * 1.1;

    // Draw grid helper lines
    final Paint linePaint = Paint()
      ..color = isDark ? const Color(0xFF330C14).withAlpha(80) : const Color(0xFFF3E6E8)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 3; i++) {
      final double y = paddingTop + (chartHeight / 3) * i;
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), linePaint);
    }

    // Coordinates points list
    final List<Offset> points = [];
    final int pointsCount = kpis.length;
    final double spacing = pointsCount > 1 ? chartWidth / (pointsCount - 1) : chartWidth;

    for (int i = 0; i < pointsCount; i++) {
      final double x = paddingLeft + i * spacing;
      final double valRatio = kpis[i].todayRevenue / maxValAdjusted;
      final double y = paddingTop + chartHeight - (chartHeight * valRatio * animationValue);
      points.add(Offset(x, y));
    }

    // Path draw
    if (points.isNotEmpty) {
      final Path fillPath = Path();
      fillPath.moveTo(paddingLeft, paddingTop + chartHeight);

      final Path strokePath = Path();
      strokePath.moveTo(points.first.dx, points.first.dy);
      fillPath.lineTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        final pPrev = points[i - 1];
        final pCurr = points[i];
        final cp1 = Offset(pPrev.dx + (pCurr.dx - pPrev.dx) / 2, pPrev.dy);
        final cp2 = Offset(pPrev.dx + (pCurr.dx - pPrev.dx) / 2, pCurr.dy);

        strokePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pCurr.dx, pCurr.dy);
        fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pCurr.dx, pCurr.dy);
      }

      fillPath.lineTo(points.last.dx, paddingTop + chartHeight);
      fillPath.close();

      // Shader fill
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFF5722).withAlpha(89),
          const Color(0xFFFF5722).withAlpha(0),
        ],
      );

      final Paint fillPaint = Paint()
        ..shader = gradient.createShader(Rect.fromLTRB(paddingLeft, paddingTop, size.width, size.height))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);

      final Paint pathPaint = Paint()
        ..color = const Color(0xFFFF5722)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(strokePath, pathPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RevenueLinePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.kpis != kpis || oldDelegate.isDark != isDark;
  }
}

class _OrdersBarPainter extends CustomPainter {
  final List<Kpi> kpis;
  final double animationValue;
  final bool isDark;

  _OrdersBarPainter({required this.kpis, required this.animationValue, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (kpis.isEmpty) return;

    final double paddingLeft = 30;
    final double paddingBottom = 20;
    final double paddingTop = 10;
    final double paddingRight = 10;

    final double chartWidth = size.width - paddingLeft - paddingRight;
    final double chartHeight = size.height - paddingTop - paddingBottom;

    final maxOrders = kpis.map((k) => k.todayOrders).reduce(max);
    final double maxValAdjusted = maxOrders == 0 ? 10 : maxOrders * 1.1;

    final double barSpacing = 8.0;
    final double totalBarsWidth = chartWidth;
    final double barWidth = max(4.0, (totalBarsWidth / kpis.length) - barSpacing);

    final Paint barPaint = Paint()
      ..color = const Color(0xFFFF5722).withAlpha(217)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < kpis.length; i++) {
      final double x = paddingLeft + (i * (barWidth + barSpacing)) + barSpacing / 2;
      final double valRatio = kpis[i].todayOrders / maxValAdjusted;
      final double barHeight = chartHeight * valRatio * animationValue;
      final double y = paddingTop + chartHeight - barHeight;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, max(2.0, barHeight)),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrdersBarPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.kpis != kpis || oldDelegate.isDark != isDark;
  }
}

class _KpiDonutPainter extends CustomPainter {
  final List<Kpi> kpis;
  final double animationValue;
  final bool isDark;

  _KpiDonutPainter({required this.kpis, required this.animationValue, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (kpis.isEmpty) return;

    int high = 0; // >=90
    int mid = 0;  // >=80
    int low = 0;  // <80

    for (var k in kpis) {
      if (k.totalKpi >= 90) {
        high++;
      } else if (k.totalKpi >= 80) {
        mid++;
      } else {
        low++;
      }
    }

    final total = kpis.length;
    final double highPercent = total > 0 ? high / total : 0.0;
    final double midPercent = total > 0 ? mid / total : 0.0;
    final double lowPercent = total > 0 ? low / total : 0.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2.2;
    final strokeWidth = radius * 0.35;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final Paint paintHigh = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Paint paintMid = Paint()
      ..color = const Color(0xFFFF9800)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Paint paintLow = Paint()
      ..color = const Color(0xFFF44336)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startAngle = -pi / 2;

    // High Bracket
    if (highPercent > 0) {
      final sweepAngle = 2 * pi * highPercent * animationValue;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paintHigh);
      startAngle += sweepAngle;
    }

    // Mid Bracket
    if (midPercent > 0) {
      final sweepAngle = 2 * pi * midPercent * animationValue;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paintMid);
      startAngle += sweepAngle;
    }

    // Low Bracket
    if (lowPercent > 0) {
      final sweepAngle = 2 * pi * lowPercent * animationValue;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paintLow);
    }
  }

  @override
  bool shouldRepaint(covariant _KpiDonutPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.kpis != kpis || oldDelegate.isDark != isDark;
  }
}

class _TopKpiBarPainter extends CustomPainter {
  final List<Kpi> kpis;
  final double animationValue;
  final bool isDark;

  _TopKpiBarPainter({required this.kpis, required this.animationValue, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (kpis.isEmpty) return;

    // Get top 4 kpis sorted
    final sortedList = List<Kpi>.from(kpis)..sort((a, b) => b.totalKpi.compareTo(a.totalKpi));
    final limit = min(4, sortedList.length);

    final double labelWidth = 60.0;
    final double paddingRight = 40.0;
    final double barHeight = 16.0;
    final double spacing = 10.0;
    final double paddingTop = 15.0;

    final Paint barPaint = Paint()
      ..color = const Color(0xFFFF5722)
      ..style = PaintingStyle.fill;

    final Paint bgPaint = Paint()
      ..color = isDark ? const Color(0xFF330C14).withAlpha(100) : const Color(0xFFF3E6E8)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < limit; i++) {
      final k = sortedList[i];
      final double y = paddingTop + i * (barHeight + spacing);

      // Draw horizontal track
      final double maxBarWidth = size.width - labelWidth - paddingRight;
      final double filledWidth = maxBarWidth * (k.totalKpi / 100.0) * animationValue;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(labelWidth, y, maxBarWidth, barHeight),
          const Radius.circular(4),
        ),
        bgPaint,
      );

      // Draw filled bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(labelWidth, y, filledWidth, barHeight),
          const Radius.circular(4),
        ),
        barPaint,
      );

      // Label text
      final textPainter = TextPainter(
        text: TextSpan(
          text: k.employeeName.split(' ').first,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(5, y + 2));

      // Value text
      final valPainter = TextPainter(
        text: TextSpan(
          text: '${k.totalKpi.toStringAsFixed(1)}%',
          style: const TextStyle(
            color: Color(0xFFFF5722),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      valPainter.paint(canvas, Offset(labelWidth + maxBarWidth + 4, y + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _TopKpiBarPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.kpis != kpis || oldDelegate.isDark != isDark;
  }
}
