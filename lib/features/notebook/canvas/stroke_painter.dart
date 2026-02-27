import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import 'package:study_notebook/core/models/models.dart';

/// Converts a hex color string (e.g. '#FF000000') to a [Color].
Color _hexToColor(String hex) {
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}

/// Renders all completed strokes and the active (in-progress) stroke.
class StrokePainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? activeStroke;
  final String? selectedStrokeId;

  StrokePainter({
    required this.strokes,
    this.activeStroke,
    this.selectedStrokeId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
      if (stroke.id == selectedStrokeId) {
        _drawSelectionHighlight(canvas, stroke);
      }
    }
    if (activeStroke != null) {
      _drawStroke(canvas, activeStroke!);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final isHighlighter = stroke.toolType == 'highlighter';
    final color = _hexToColor(stroke.color);

    final paint = Paint()
      ..color = isHighlighter ? color.withValues(alpha: 0.35) : color
      ..style = PaintingStyle.fill
      ..blendMode = isHighlighter ? BlendMode.multiply : BlendMode.srcOver;

    // Convert stroke points to perfect_freehand input.
    final inputPoints = stroke.points
        .map((p) => PointVector(p.x, p.y, p.pressure))
        .toList();

    final outlinePoints = getStroke(
      inputPoints,
      options: StrokeOptions(
        size: stroke.strokeWidth,
        thinning: isHighlighter ? 0.0 : 0.5,
        smoothing: 0.5,
        streamline: 0.5,
        simulatePressure: stroke.points.every((p) => p.pressure == 1.0),
      ),
    );

    if (outlinePoints.isEmpty) return;

    final path = Path();
    if (outlinePoints.length == 1) {
      path.addOval(Rect.fromCircle(
        center: outlinePoints[0],
        radius: stroke.strokeWidth / 2,
      ));
    } else {
      path.moveTo(outlinePoints[0].dx, outlinePoints[0].dy);
      for (var i = 1; i < outlinePoints.length - 1; i++) {
        final p0 = outlinePoints[i];
        final p1 = outlinePoints[i + 1];
        path.quadraticBezierTo(
          p0.dx,
          p0.dy,
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawSelectionHighlight(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final inputPoints = stroke.points
        .map((p) => PointVector(p.x, p.y, p.pressure))
        .toList();

    final outlinePoints = getStroke(
      inputPoints,
      options: StrokeOptions(
        size: stroke.strokeWidth + 6,
        thinning: stroke.toolType == 'highlighter' ? 0.0 : 0.5,
        smoothing: 0.5,
        streamline: 0.5,
        simulatePressure: stroke.points.every((p) => p.pressure == 1.0),
      ),
    );

    if (outlinePoints.isEmpty) return;

    final path = Path();
    if (outlinePoints.length == 1) {
      path.addOval(Rect.fromCircle(
        center: outlinePoints[0],
        radius: stroke.strokeWidth / 2 + 3,
      ));
    } else {
      path.moveTo(outlinePoints[0].dx, outlinePoints[0].dy);
      for (var i = 1; i < outlinePoints.length - 1; i++) {
        final p0 = outlinePoints[i];
        final p1 = outlinePoints[i + 1];
        path.quadraticBezierTo(
          p0.dx, p0.dy,
          (p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2,
        );
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x662196F3)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2196F3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.activeStroke != activeStroke ||
        oldDelegate.selectedStrokeId != selectedStrokeId;
  }
}
