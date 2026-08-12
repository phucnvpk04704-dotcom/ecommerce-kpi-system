import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

class ReportChart extends StatelessWidget {
  final List<dynamic> data;
  final String xKey;
  final String yKey;
  final String type; // 'revenue' or 'orders'

  const ReportChart({
    super.key,
    required this.data,
    required this.xKey,
    required this.yKey,
    required this.type,
  });

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
                  type == 'revenue' ? 'Revenue Trends' : 'Orders Distributions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2B0008),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                type == 'revenue' ? Icons.show_chart_rounded : Icons.bar_chart_rounded,
                color: const Color(0xFFFF5722),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: data.isEmpty
                ? const Center(child: Text('No trend logs available', style: TextStyle(color: Colors.grey)))
                : CustomPaint(
                    painter: _ChartPainter(
                      data: data,
                      xKey: xKey,
                      yKey: yKey,
                      type: type,
                      isDark: isDark,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<dynamic> data;
  final String xKey;
  final String yKey;
  final String type;
  final bool isDark;

  _ChartPainter({
    required this.data,
    required this.xKey,
    required this.yKey,
    required this.type,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = const Color(0xFFFF5722)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    // Draw horizontal grid lines
    const gridLines = 4;
    final rowHeight = size.height / gridLines;
    for (int i = 0; i <= gridLines; i++) {
      final y = i * rowHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final double maxVal = data.fold(1.0, (double maxSoFar, item) {
      final val = double.tryParse(item[yKey]?.toString() ?? '0.0') ?? 0.0;
      return max(maxSoFar, val);
    });

    final double stepX = size.width / (data.length - 1 == 0 ? 1 : data.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final val = double.tryParse(data[i][yKey]?.toString() ?? '0.0') ?? 0.0;
      final x = i * stepX;
      final ratio = maxVal == 0 ? 0.0 : (val / maxVal);
      final y = size.height - (ratio * (size.height - 20)) - 10;
      points.add(Offset(x, y));
    }

    // Gradient fill path below the line
    if (points.isNotEmpty) {
      final fillPath = Path()
        ..moveTo(0, size.height);
      for (var pt in points) {
        fillPath.lineTo(pt.dx, pt.dy);
      }
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();

      fillPaint.shader = LinearGradient(
        colors: [
          const Color(0xFFFF5722).withAlpha(80),
          const Color(0xFFFF5722).withAlpha(0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw lines
    if (points.length > 1) {
      final linePath = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(linePath, linePaint);
    }

    // Draw markers & text labels
    final textPaint = TextStyle(
      color: isDark ? Colors.white70 : Colors.black87,
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );

    final currencyFormat = NumberFormat.compact(locale: 'vi_VN');

    for (int i = 0; i < points.length; i++) {
      // Circle dot marker
      final dotPaint = Paint()
        ..color = const Color(0xFFFF5722)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(points[i], 4, dotPaint);

      final dotOuter = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(points[i], 4, dotOuter);

      // Value text above the dot
      final valNum = double.tryParse(data[i][yKey]?.toString() ?? '0.0') ?? 0.0;
      final valStr = type == 'revenue' ? currencyFormat.format(valNum) : valNum.toStringAsFixed(0);
      final valSpan = TextSpan(text: valStr, style: textPaint);
      final valTp = TextPainter(text: valSpan, textDirection: TextDirection.ltr)..layout();
      valTp.paint(canvas, Offset(points[i].dx - (valTp.width / 2), points[i].dy - 16));

      // X-Axis text labels below the dot
      final xStr = data[i][xKey]?.toString() ?? '';
      final xSpan = TextSpan(text: xStr, style: textPaint);
      final xTp = TextPainter(text: xSpan, textDirection: TextDirection.ltr)..layout();
      xTp.paint(canvas, Offset(points[i].dx - (xTp.width / 2), size.height + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}
