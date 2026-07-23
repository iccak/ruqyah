import 'dart:math' as math;
import 'package:flutter/material.dart';

/// خلفية زخرفية خفيفة بنمط نجمي هندسي (ثماني الرؤوس) تُستخدم خلف
/// عناوين الشاشات الرئيسية، مستوحاة من الزخارف الإسلامية التقليدية.
/// النمط باهت جدًا (شفافية منخفضة) كي لا يؤثر على وضوح النص فوقه.
class StarPatternBackground extends StatelessWidget {
  final Widget child;
  final Color patternColor;

  const StarPatternBackground({
    super.key,
    required this.child,
    required this.patternColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarPatternPainter(color: patternColor),
      child: child,
    );
  }
}

class _StarPatternPainter extends CustomPainter {
  final Color color;
  const _StarPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const spacing = 46.0;
    const starRadius = 15.0;

    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      final rowOffset = ((y / spacing).round().isOdd) ? spacing / 2 : 0.0;
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        _drawStar(canvas, Offset(x + rowOffset, y), starRadius, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    // نجمة ثمانية الرؤوس: مربعان متقاطعان بزاوية 45 درجة
    final path1 = Path();
    final path2 = Path();
    for (int i = 0; i < 4; i++) {
      final angle1 = (i * 90) * math.pi / 180;
      final angle2 = angle1 + (math.pi / 4);
      final p1 = Offset(
        center.dx + radius * math.cos(angle1),
        center.dy + radius * math.sin(angle1),
      );
      final p2 = Offset(
        center.dx + radius * math.cos(angle2),
        center.dy + radius * math.sin(angle2),
      );
      if (i == 0) {
        path1.moveTo(p1.dx, p1.dy);
        path2.moveTo(p2.dx, p2.dy);
      } else {
        path1.lineTo(p1.dx, p1.dy);
        path2.lineTo(p2.dx, p2.dy);
      }
    }
    path1.close();
    path2.close();
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _StarPatternPainter oldDelegate) => false;
}
