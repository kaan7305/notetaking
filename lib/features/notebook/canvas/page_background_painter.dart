import 'package:flutter/material.dart';

/// Paints page backgrounds: blank, lined, grid, or dotted.
class PageBackgroundPainter extends CustomPainter {
  final String templateType;
  final Color lineColor;
  final double lineSpacing;

  PageBackgroundPainter({
    required this.templateType,
    Color? lineColor,
    this.lineSpacing = 32.0,
  }) : lineColor = lineColor ?? Colors.blue.withValues(alpha: 0.15);

  @override
  void paint(Canvas canvas, Size size) {
    switch (templateType) {
      case 'lined':
        _drawLined(canvas, size);
      case 'grid':
        _drawGrid(canvas, size);
      case 'dotted':
        _drawDotted(canvas, size);
      case 'blank':
      default:
        break;
    }
  }

  void _drawLined(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5;

    for (var y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5;

    for (var y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (var x = lineSpacing; x < size.width; x += lineSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _drawDotted(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (var y = lineSpacing; y < size.height; y += lineSpacing) {
      for (var x = lineSpacing; x < size.width; x += lineSpacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(PageBackgroundPainter oldDelegate) {
    return oldDelegate.templateType != templateType ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.lineSpacing != lineSpacing;
  }
}
