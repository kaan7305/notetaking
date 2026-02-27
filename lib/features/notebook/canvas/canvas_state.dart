import 'package:flutter/material.dart';
import 'package:study_notebook/core/models/models.dart';

/// Immutable state for the drawing canvas.
class CanvasState {
  final List<Stroke> strokes;
  final Stroke? activeStroke;
  final List<TextElement> textElements;
  final String? activeTextId;
  final String? selectedStrokeId;
  final ToolType currentTool;
  final Color currentColor;
  final double strokeWidth;
  final double highlighterWidth;
  final double eraserRadius;
  final List<List<Stroke>> undoStack;
  final List<List<Stroke>> redoStack;
  final Offset canvasOffset;
  final double zoom;
  final Offset? hoverPosition;

  const CanvasState({
    this.strokes = const [],
    this.activeStroke,
    this.textElements = const [],
    this.activeTextId,
    this.selectedStrokeId,
    this.currentTool = ToolType.pen,
    this.currentColor = const Color(0xFF000000),
    this.strokeWidth = 2.0,
    this.highlighterWidth = 20.0,
    this.eraserRadius = 15.0,
    this.undoStack = const [],
    this.redoStack = const [],
    this.canvasOffset = Offset.zero,
    this.zoom = 1.0,
    this.hoverPosition,
  });

  double get activeStrokeWidth {
    switch (currentTool) {
      case ToolType.pen:
        return strokeWidth;
      case ToolType.highlighter:
        return highlighterWidth;
      case ToolType.eraser:
        return eraserRadius * 2;
      default:
        return strokeWidth;
    }
  }

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  CanvasState copyWith({
    List<Stroke>? strokes,
    Stroke? Function()? activeStroke,
    List<TextElement>? textElements,
    String? Function()? activeTextId,
    String? Function()? selectedStrokeId,
    ToolType? currentTool,
    Color? currentColor,
    double? strokeWidth,
    double? highlighterWidth,
    double? eraserRadius,
    List<List<Stroke>>? undoStack,
    List<List<Stroke>>? redoStack,
    Offset? canvasOffset,
    double? zoom,
    Offset? Function()? hoverPosition,
  }) {
    return CanvasState(
      strokes: strokes ?? this.strokes,
      activeStroke:
          activeStroke != null ? activeStroke() : this.activeStroke,
      textElements: textElements ?? this.textElements,
      activeTextId: activeTextId != null ? activeTextId() : this.activeTextId,
      selectedStrokeId: selectedStrokeId != null ? selectedStrokeId() : this.selectedStrokeId,
      currentTool: currentTool ?? this.currentTool,
      currentColor: currentColor ?? this.currentColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      highlighterWidth: highlighterWidth ?? this.highlighterWidth,
      eraserRadius: eraserRadius ?? this.eraserRadius,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      canvasOffset: canvasOffset ?? this.canvasOffset,
      zoom: zoom ?? this.zoom,
      hoverPosition: hoverPosition != null ? hoverPosition() : this.hoverPosition,
    );
  }
}
