import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/core/models/models.dart';

import 'canvas_notifier.dart';
import 'page_background_painter.dart';
import 'stroke_painter.dart';

/// The main drawing surface that handles pointer input and renders strokes.
class DrawingCanvas extends ConsumerWidget {
  final String pageId;
  final String templateType;
  final Size pageSize;

  const DrawingCanvas({
    super.key,
    required this.pageId,
    required this.templateType,
    required this.pageSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider(pageId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: RepaintBoundary(
        child: Listener(
          onPointerDown: (event) {
            final notifier = ref.read(canvasProvider(pageId).notifier);
            notifier.onPointerDown(
              event.localPosition,
              event.pressure > 0 ? event.pressure : 0.5,
            );
          },
          onPointerMove: (event) {
            final notifier = ref.read(canvasProvider(pageId).notifier);
            notifier.onPointerMove(
              event.localPosition,
              event.pressure > 0 ? event.pressure : 0.5,
            );
          },
          onPointerUp: (_) {
            ref.read(canvasProvider(pageId).notifier).onPointerUp();
          },
          child: Stack(
            children: [
              // Page background (template pattern).
              CustomPaint(
                size: pageSize,
                painter: PageBackgroundPainter(
                  templateType: templateType,
                  lineColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : null,
                ),
              ),
              // Strokes layer.
              CustomPaint(
                size: pageSize,
                painter: StrokePainter(
                  strokes: canvasState.strokes,
                  activeStroke: canvasState.activeStroke,
                ),
              ),
              // Tool cursor overlay.
              if (canvasState.currentTool == ToolType.eraser)
                Positioned.fill(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.precise,
                    child: const SizedBox.expand(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
