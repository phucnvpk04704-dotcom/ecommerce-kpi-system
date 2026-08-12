import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../models/dashboard_stats.dart';

class Revenue7DaysChart extends StatefulWidget {
  final List<ChartDataPoint> data;

  const Revenue7DaysChart({super.key, required this.data});

  @override
  State<Revenue7DaysChart> createState() => _Revenue7DaysChartState();
}

class _Revenue7DaysChartState extends State<Revenue7DaysChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant Revenue7DaysChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.reset();
    _controller.forward();
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
      height: 220,
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
            'Revenue (7 Days)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2B0008),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _RevenueLinePainter(
                    data: widget.data,
                    animationValue: _animation.value,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueLinePainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final double animationValue;
  final bool isDark;

  _RevenueLinePainter({
    required this.data,
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double maxVal = data.map((d) => d.value).reduce(math.max);
    final double maxValAdjusted = maxVal == 0 ? 1000000.0 : maxVal * 1.15;

    final double paddingLeft = 60.0;
    final double paddingBottom = 24.0;
    final double paddingTop = 8.0;
    final double paddingRight = 10.0;

    final double chartWidth = size.width - paddingLeft - paddingRight;
    final double chartHeight = size.height - paddingTop - paddingBottom;

    // Draw gridlines & Y labels
    final int gridLinesCount = 4;
    final Paint gridPaint = Paint()
      ..color = isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8)
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final currencyFormat = NumberFormat.compact(locale: 'vi_VN');

    for (int i = 0; i <= gridLinesCount; i++) {
      final double y = paddingTop + chartHeight - (chartHeight / gridLinesCount) * i;
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);

      // Y Label
      final double labelValue = (maxValAdjusted / gridLinesCount) * i;
      textPainter.text = TextSpan(
        text: currencyFormat.format(labelValue),
        style: TextStyle(
          fontSize: 10,
          color: isDark ? const Color(0xFFCCA5AB) : const Color(0xFF8C7174),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(paddingLeft - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    // Prepare line path
    final double segmentWidth = chartWidth / (data.length - 1 == 0 ? 1 : data.length - 1);
    final Path linePath = Path();
    final Path fillPath = Path();

    final List<Offset> points = [];

    for (int i = 0; i < data.length; i++) {
      final double x = paddingLeft + i * segmentWidth;
      final double valRatio = data[i].value / maxValAdjusted;
      final double y = paddingTop + chartHeight - (chartHeight * valRatio * animationValue);
      final offset = Offset(x, y);
      points.add(offset);

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, paddingTop + chartHeight);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      if (i == data.length - 1) {
        fillPath.lineTo(x, paddingTop + chartHeight);
        fillPath.close();
      }
    }

    // Draw Fill (Gradient)
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

    // Draw Curve Line
    final Paint linePaint = Paint()
      ..color = const Color(0xFFFF5722)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, linePaint);

    // Draw data points & X Labels
    final Paint pointPaint = Paint()
      ..color = const Color(0xFFFF5722)
      ..style = PaintingStyle.fill;

    final Paint pointBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < data.length; i++) {
      final offset = points[i];

      // Draw point
      canvas.drawCircle(offset, 5.0, pointPaint);
      canvas.drawCircle(offset, 5.0, pointBorderPaint);

      // X Label
      textPainter.text = TextSpan(
        text: data[i].label,
        style: TextStyle(
          fontSize: 9,
          color: isDark ? const Color(0xFFCCA5AB) : const Color(0xFF8C7174),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(offset.dx - textPainter.width / 2, size.height - paddingBottom + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RevenueLinePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.data != data;
  }
}

class Orders7DaysChart extends StatefulWidget {
  final List<ChartDataPoint> data;

  const Orders7DaysChart({super.key, required this.data});

  @override
  State<Orders7DaysChart> createState() => _Orders7DaysChartState();
}

class _Orders7DaysChartState extends State<Orders7DaysChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant Orders7DaysChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.reset();
    _controller.forward();
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
      height: 220,
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
            'Orders (7 Days)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2B0008),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _OrdersBarPainter(
                    data: widget.data,
                    animationValue: _animation.value,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersBarPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final double animationValue;
  final bool isDark;

  _OrdersBarPainter({
    required this.data,
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double maxVal = data.map((d) => d.value).reduce(math.max);
    final double maxValAdjusted = maxVal == 0 ? 100.0 : maxVal * 1.15;

    final double paddingLeft = 40.0;
    final double paddingBottom = 24.0;
    final double paddingTop = 8.0;
    final double paddingRight = 10.0;

    final double chartWidth = size.width - paddingLeft - paddingRight;
    final double chartHeight = size.height - paddingTop - paddingBottom;

    final Paint gridPaint = Paint()
      ..color = isDark ? const Color(0xFF330C14) : const Color(0xFFF3E6E8)
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw gridlines & Y labels
    final int gridLinesCount = 4;
    for (int i = 0; i <= gridLinesCount; i++) {
      final double y = paddingTop + chartHeight - (chartHeight / gridLinesCount) * i;
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);

      final double labelValue = (maxValAdjusted / gridLinesCount) * i;
      textPainter.text = TextSpan(
        text: labelValue.toInt().toString(),
        style: TextStyle(
          fontSize: 10,
          color: isDark ? const Color(0xFFCCA5AB) : const Color(0xFF8C7174),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(paddingLeft - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    final double spacingRatio = 0.35;
    final double totalBarsWidth = chartWidth;
    final double barWidth = (totalBarsWidth / data.length) * (1 - spacingRatio);
    final double barSpacing = (totalBarsWidth / data.length) * spacingRatio;

    final Paint barPaint = Paint()
      ..color = const Color(0xFFFF5722).withAlpha(217)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final double x = paddingLeft + (i * (barWidth + barSpacing)) + barSpacing / 2;
      final double valRatio = data[i].value / maxValAdjusted;
      final double barHeight = chartHeight * valRatio * animationValue;
      final double y = paddingTop + chartHeight - barHeight;

      // Draw rounded bar
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rect, barPaint);

      // X Label
      textPainter.text = TextSpan(
        text: data[i].label,
        style: TextStyle(
          fontSize: 9,
          color: isDark ? const Color(0xFFCCA5AB) : const Color(0xFF8C7174),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, size.height - paddingBottom + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrdersBarPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.data != data;
  }
}

class KpiDistributionChart extends StatefulWidget {
  final List<ChartDataPoint> data;

  const KpiDistributionChart({super.key, required this.data});

  @override
  State<KpiDistributionChart> createState() => _KpiDistributionChartState();
}

class _KpiDistributionChartState extends State<KpiDistributionChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant KpiDistributionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.reset();
    _controller.forward();
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

    final List<Color> colors = const [
      Color(0xFF4CAF50), // Green for excellent
      Color(0xFFFF9800), // Orange for good
      Color(0xFF2196F3), // Blue for average
      Color(0xFFF44336), // Red for below
    ];

    return Container(
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
            'KPI Distribution',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2B0008),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 130,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _KpiDonutPainter(
                          data: widget.data,
                          animationValue: _animation.value,
                          colors: colors,
                          isDark: isDark,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.data.length, (idx) {
                    final item = widget.data[idx];
                    final color = colors[idx % colors.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.label} (${item.value.toStringAsFixed(0)}%)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? const Color(0xFFCCA5AB) : const Color(0xFF6E5256),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiDonutPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final double animationValue;
  final List<Color> colors;
  final bool isDark;

  _KpiDonutPainter({
    required this.data,
    required this.animationValue,
    required this.colors,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double total = data.map((d) => d.value).reduce((a, b) => a + b);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    double startAngle = -math.pi / 2;

    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final rect = Rect.fromCircle(center: center, radius: radius);

    for (int i = 0; i < data.length; i++) {
      final double sweepAngle = (data[i].value / total) * 2 * math.pi * animationValue;
      paint.color = colors[i % colors.length];

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    // Draw donut cutout hole
    final cutoutPaint = Paint()
      ..color = isDark ? const Color(0xFF1D0308) : Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.55, cutoutPaint);
  }

  @override
  bool shouldRepaint(covariant _KpiDonutPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.data != data;
  }
}
