import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import 'package:study_notebook/core/models/models.dart';

/// Converts a hex color string (e.g. '#FF000000') to a [Color].
Color _hexToColor(String hex) {
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}

/// Renders all completed strokes and the active (in-progress) stroke,
/// plus selection outlines for lasso/box selection.
class StrokePainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? activeStroke;
  final Set<String> selectedStrokeIds;
  final List<Offset>? selectionLassoPoints;
  final Rect? selectionRect;
  final bool isSelecting;

  StrokePainter({
    required this.strokes,
    this.activeStroke,
    this.selectedStrokeIds = const {},
    this.selectionLassoPoints,
    this.selectionRect,
    this.isSelecting = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
      if (selectedStrokeIds.contains(stroke.id)) {
        _drawSelectionHighlight(canvas, stroke);
      }
    }
    if (activeStroke != null) {
      _drawStroke(canvas, activeStroke!);
    }

    _drawSelectionOutline(canvas);
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

    // Determine StrokeOptions based on pen style.
    StrokeOptions options;
    if (isHighlighter) {
      options = StrokeOptions(
        size: stroke.strokeWidth,
        thinning: 0.0,
        smoothing: 0.5,
        streamline: 0.5,
        simulatePressure: stroke.points.every((p) => p.pressure == 1.0),
      );
    } else {
      final penStyle = PenStyle.values.firstWhere(
        (s) => s.name == stroke.penStyle,
        orElse: () => PenStyle.standard,
      );
      final config = PenStyleConfig.forStyle(penStyle);
      options = StrokeOptions(
        size: stroke.strokeWidth,
        thinning: config.thinning,
        smoothing: config.smoothing,
        streamline: config.streamline,
        simulatePressure: stroke.points.every((p) => p.pressure == 1.0),
      );
    }

    final outlinePoints = getStroke(inputPoints, options: options);
    if (outlinePoints.isEmpty) return;

    final path = _buildPath(outlinePoints, stroke.strokeWidth);

    // Pencil style: slightly translucent for overlapping buildup.
    if (!isHighlighter && stroke.penStyle == 'pencil') {
      paint.color = color.withValues(alpha: 0.7);
    }

    canvas.drawPath(path, paint);
  }

  void _drawSelectionHighlight(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final isHighlighter = stroke.toolType == 'highlighter';
    final penStyle = PenStyle.values.firstWhere(
      (s) => s.name == stroke.penStyle,
      orElse: () => PenStyle.standard,
    );
    final config = PenStyleConfig.forStyle(penStyle);

    final inputPoints = stroke.points
        .map((p) => PointVector(p.x, p.y, p.pressure))
        .toList();

    final outlinePoints = getStroke(
      inputPoints,
      options: StrokeOptions(
        size: stroke.strokeWidth + 6,
        thinning: isHighlighter ? 0.0 : config.thinning,
        smoothing: config.smoothing,
        streamline: config.streamline,
        simulatePressure: stroke.points.every((p) => p.pressure == 1.0),
      ),
    );

    if (outlinePoints.isEmpty) return;

    final path = _buildPath(outlinePoints, stroke.strokeWidth + 6);

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

  void _drawSelectionOutline(Canvas canvas) {
    if (selectionLassoPoints == null && selectionRect == null) return;

    final outlinePaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = const Color(0x1A2196F3)
      ..style = PaintingStyle.fill;

    if (selectionLassoPoints != null && selectionLassoPoints!.length >= 2) {
      final path = Path();
      path.moveTo(selectionLassoPoints![0].dx, selectionLassoPoints![0].dy);
      for (var i = 1; i < selectionLassoPoints!.length; i++) {
        path.lineTo(selectionLassoPoints![i].dx, selectionLassoPoints![i].dy);
      }
      if (!isSelecting) path.close();
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, outlinePaint);
    }

    if (selectionRect != null) {
      final rect = Rect.fromLTRB(
        selectionRect!.left < selectionRect!.right
            ? selectionRect!.left
            : selectionRect!.right,
        selectionRect!.top < selectionRect!.bottom
            ? selectionRect!.top
            : selectionRect!.bottom,
        selectionRect!.left < selectionRect!.right
            ? selectionRect!.right
            : selectionRect!.left,
        selectionRect!.top < selectionRect!.bottom
            ? selectionRect!.bottom
            : selectionRect!.top,
      );
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, outlinePaint);
    }
  }

  Path _buildPath(List<Offset> outlinePoints, double strokeWidth) {
    final path = Path();
    if (outlinePoints.length == 1) {
      path.addOval(Rect.fromCircle(
        center: outlinePoints[0],
        radius: strokeWidth / 2,
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
    return path;
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.activeStroke != activeStroke ||
        oldDelegate.selectedStrokeIds != selectedStrokeIds ||
        oldDelegate.selectionLassoPoints != selectionLassoPoints ||
        oldDelegate.selectionRect != selectionRect ||
        oldDelegate.isSelecting != isSelecting;
  }
}
