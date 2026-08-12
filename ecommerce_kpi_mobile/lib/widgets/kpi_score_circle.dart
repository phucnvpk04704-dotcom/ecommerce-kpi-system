import 'dart:math';
import 'package:flutter/material.dart';

class KpiScoreCircle extends StatefulWidget {
  final double score;
  final double radius;

  const KpiScoreCircle({
    super.key,
    required this.score,
    this.radius = 80,
  });

  @override
  State<KpiScoreCircle> createState() => _KpiScoreCircleState();
}

class _KpiScoreCircleState extends State<KpiScoreCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant KpiScoreCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(begin: _animation.value, end: widget.score).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
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

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentScore = _animation.value;
        final scoreColor = _getKpiColor(currentScore);

        return Center(
          child: Column(
            children: [
              CustomPaint(
                size: Size(widget.radius * 2, widget.radius * 2),
                painter: _ScoreCirclePainter(
                  score: currentScore,
                  color: scoreColor,
                  isDark: isDark,
                ),
                child: SizedBox(
                  width: widget.radius * 2,
                  height: widget.radius * 2,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${currentScore.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: widget.radius * 0.4,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                        Text(
                          'Overall KPI',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getKpiColor(double score) {
    if (score >= 90) return const Color(0xFF4CAF50);
    if (score >= 80) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}

class _ScoreCirclePainter extends CustomPainter {
  final double score;
  final Color color;
  final bool isDark;

  _ScoreCirclePainter({
    required this.score,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.12;

    // Background track paint
    final Paint trackPaint = Paint()
      ..color = isDark ? const Color(0xFF330C14).withAlpha(100) : const Color(0xFFF3E6E8)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius - strokeWidth / 2, trackPaint);

    // Active arc paint
    final Paint arcPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double startAngle = -pi / 2;
    final double sweepAngle = 2 * pi * (score / 100.0).clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreCirclePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color || oldDelegate.isDark != isDark;
  }
}
