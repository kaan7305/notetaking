import 'package:flutter/material.dart';
import 'package:study_notebook/core/models/models.dart';

/// Immutable state for the drawing canvas.
class CanvasState {
  final List<Stroke> strokes;
  final Stroke? activeStroke;
  final List<TextElement> textElements;
  final String? activeTextId;
  final Set<String> selectedStrokeIds;
  final Set<String> selectedTextIds;
  final ToolType currentTool;
  final Color currentColor;
  final double strokeWidth;
  final double highlighterWidth;
  final double eraserRadius;
  final PenStyle currentPenStyle;
  final SelectionMode selectionMode;
  final List<Offset>? selectionLassoPoints;
  final Rect? selectionRect;
  final bool isSelecting;
  final List<(List<Stroke>, List<TextElement>)> undoStack;
  final List<(List<Stroke>, List<TextElement>)> redoStack;
  final Offset canvasOffset;
  final double zoom;
  final Offset? hoverPosition;

  /// Non-null when the initial DB load failed. The canvas remains usable
  /// (strokes drawn in this session are still saved) but previously saved
  /// content could not be retrieved.
  final String? loadError;

  const CanvasState({
    this.strokes = const [],
    this.activeStroke,
    this.textElements = const [],
    this.activeTextId,
    this.selectedStrokeIds = const {},
    this.selectedTextIds = const {},
    this.currentTool = ToolType.pen,
    this.currentColor = const Color(0xFF000000),
    this.strokeWidth = 2.0,
    this.highlighterWidth = 20.0,
    this.eraserRadius = 15.0,
    this.currentPenStyle = PenStyle.standard,
    this.selectionMode = SelectionMode.freeform,
    this.selectionLassoPoints,
    this.selectionRect,
    this.isSelecting = false,
    this.undoStack = const [],
    this.redoStack = const [],
    this.canvasOffset = Offset.zero,
    this.zoom = 1.0,
    this.hoverPosition,
    this.loadError,
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
  bool get hasSelection =>
      selectedStrokeIds.isNotEmpty || selectedTextIds.isNotEmpty;

  CanvasState copyWith({
    List<Stroke>? strokes,
    Stroke? Function()? activeStroke,
    List<TextElement>? textElements,
    String? Function()? activeTextId,
    Set<String>? selectedStrokeIds,
    Set<String>? selectedTextIds,
    ToolType? currentTool,
    Color? currentColor,
    double? strokeWidth,
    double? highlighterWidth,
    double? eraserRadius,
    PenStyle? currentPenStyle,
    SelectionMode? selectionMode,
    List<Offset>? Function()? selectionLassoPoints,
    Rect? Function()? selectionRect,
    bool? isSelecting,
    List<(List<Stroke>, List<TextElement>)>? undoStack,
    List<(List<Stroke>, List<TextElement>)>? redoStack,
    Offset? canvasOffset,
    double? zoom,
    Offset? Function()? hoverPosition,
    String? Function()? loadError,
  }) {
    return CanvasState(
      strokes: strokes ?? this.strokes,
      activeStroke:
          activeStroke != null ? activeStroke() : this.activeStroke,
      textElements: textElements ?? this.textElements,
      activeTextId: activeTextId != null ? activeTextId() : this.activeTextId,
      selectedStrokeIds: selectedStrokeIds ?? this.selectedStrokeIds,
      selectedTextIds: selectedTextIds ?? this.selectedTextIds,
      currentTool: currentTool ?? this.currentTool,
      currentColor: currentColor ?? this.currentColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      highlighterWidth: highlighterWidth ?? this.highlighterWidth,
      eraserRadius: eraserRadius ?? this.eraserRadius,
      currentPenStyle: currentPenStyle ?? this.currentPenStyle,
      selectionMode: selectionMode ?? this.selectionMode,
      selectionLassoPoints: selectionLassoPoints != null
          ? selectionLassoPoints()
          : this.selectionLassoPoints,
      selectionRect: selectionRect != null
          ? selectionRect()
          : this.selectionRect,
      isSelecting: isSelecting ?? this.isSelecting,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      canvasOffset: canvasOffset ?? this.canvasOffset,
      zoom: zoom ?? this.zoom,
      hoverPosition: hoverPosition != null ? hoverPosition() : this.hoverPosition,
      loadError: loadError != null ? loadError() : this.loadError,
    );
  }
}
