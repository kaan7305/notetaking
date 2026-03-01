import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/storage/storage.dart';
import 'package:study_notebook/core/utils/constants.dart';

import 'canvas_state.dart';

/// Manages all drawing state for a single page.
class CanvasNotifier extends StateNotifier<CanvasState> {
  final StrokeDao _strokeDao;
  final TextElementDao _textDao;
  final String pageId;
  Timer? _autoSaveTimer;
  bool _needsSave = false;

  CanvasNotifier({
    required this.pageId,
    StrokeDao? strokeDao,
    TextElementDao? textDao,
  })  : _strokeDao = strokeDao ?? StrokeDao(),
        _textDao = textDao ?? TextElementDao(),
        super(const CanvasState()) {
    _loadAll();
  }

  // ─────────────── Loading ───────────────

  Future<void> _loadAll() async {
    final strokeResult = await _strokeDao.getByPageId(pageId);
    final textResult = await _textDao.getByPageId(pageId);

    final strokes = strokeResult is Success<List<Stroke>>
        ? strokeResult.data
        : <Stroke>[];
    final texts = textResult is Success<List<TextElement>>
        ? textResult.data
        : <TextElement>[];

    // Collect any load errors to surface in the UI.
    String? error;
    if (strokeResult is Failure) {
      error = (strokeResult as Failure).message;
    } else if (textResult is Failure) {
      error = (textResult as Failure).message;
    }

    state = state.copyWith(
      strokes: strokes,
      textElements: texts,
      loadError: () => error,
    );
  }

  // ─────────────── Error handling ───────────────

  /// Clears the load error banner so the user can dismiss it.
  void dismissLoadError() {
    state = state.copyWith(loadError: () => null);
  }

  // ─────────────── Tool selection ───────────────

  void selectTool(ToolType tool) {
    state = state.copyWith(
      currentTool: tool,
      selectedStrokeIds: {},
      selectedTextIds: {},
      selectionLassoPoints: () => null,
      selectionRect: () => null,
      isSelecting: false,
    );
  }

  void selectColor(Color color) {
    state = state.copyWith(currentColor: color);
  }

  void setStrokeWidth(double width) {
    state = state.copyWith(strokeWidth: width);
  }

  void setHighlighterWidth(double width) {
    state = state.copyWith(highlighterWidth: width);
  }

  void setEraserRadius(double radius) {
    state = state.copyWith(eraserRadius: radius.clamp(5.0, 80.0));
  }

  void onHover(Offset position) {
    state = state.copyWith(hoverPosition: () => position);
  }

  void onHoverExit() {
    state = state.copyWith(hoverPosition: () => null);
  }

  // ─────────────── Pen style ───────────────

  void selectPenStyle(PenStyle style) {
    final config = PenStyleConfig.forStyle(style);
    state = state.copyWith(
      currentPenStyle: style,
      strokeWidth: config.defaultWidth,
    );
  }

  // ─────────────── Selection mode ───────────────

  void setSelectionMode(SelectionMode mode) {
    state = state.copyWith(selectionMode: mode);
  }

  // ─────────────── Drawing ───────────────

  void onPointerDown(Offset position, double pressure) {
    if (state.currentTool == ToolType.pointer) {
      _hitTestStroke(position);
      return;
    }
    if (state.currentTool == ToolType.lasso) {
      _startSelection(position);
      return;
    }
    if (state.currentTool == ToolType.eraser) {
      _eraseAt(position);
      return;
    }
    if (state.currentTool != ToolType.pen &&
        state.currentTool != ToolType.highlighter) {
      return;
    }

    final point = StrokePoint(
      x: position.dx,
      y: position.dy,
      pressure: pressure.clamp(0.1, 1.0),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final toolType =
        state.currentTool == ToolType.highlighter ? 'highlighter' : 'pen';
    final color =
        '#${state.currentColor.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

    final stroke = Stroke(
      id: const Uuid().v4(),
      pageId: pageId,
      toolType: toolType,
      color: color,
      strokeWidth: state.activeStrokeWidth,
      points: [point],
      createdAt: DateTime.now(),
      penStyle: state.currentPenStyle.name,
    );

    state = state.copyWith(activeStroke: () => stroke);
  }

  void onPointerMove(Offset position, double pressure) {
    if (state.currentTool == ToolType.eraser) {
      _eraseAt(position);
      return;
    }
    if (state.currentTool == ToolType.lasso && state.isSelecting) {
      _updateSelection(position);
      return;
    }

    final active = state.activeStroke;
    if (active == null) return;

    final point = StrokePoint(
      x: position.dx,
      y: position.dy,
      pressure: pressure.clamp(0.1, 1.0),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final updated = Stroke(
      id: active.id,
      pageId: active.pageId,
      toolType: active.toolType,
      color: active.color,
      strokeWidth: active.strokeWidth,
      points: [...active.points, point],
      createdAt: active.createdAt,
      penStyle: active.penStyle,
    );

    state = state.copyWith(activeStroke: () => updated);
  }

  void onPointerUp() {
    if (state.currentTool == ToolType.lasso && state.isSelecting) {
      _finalizeSelection();
      return;
    }

    final active = state.activeStroke;
    if (active == null) return;

    // Only add strokes with at least 2 points (otherwise it's just a tap).
    if (active.points.length < 2) {
      state = state.copyWith(activeStroke: () => null);
      return;
    }

    _pushUndoState();
    final newStrokes = [...state.strokes, active];
    state = state.copyWith(
      strokes: newStrokes,
      activeStroke: () => null,
      redoStack: [],
    );
    _markDirty();
  }

  // ─────────────── Eraser ───────────────

  void _eraseAt(Offset position) {
    final hitRadius = state.eraserRadius;
    final toRemove = <String>[];

    for (final stroke in state.strokes) {
      for (final point in stroke.points) {
        final dx = point.x - position.dx;
        final dy = point.y - position.dy;
        if (dx * dx + dy * dy < hitRadius * hitRadius) {
          toRemove.add(stroke.id);
          break;
        }
      }
    }

    if (toRemove.isNotEmpty) {
      _pushUndoState();
      final newStrokes =
          state.strokes.where((s) => !toRemove.contains(s.id)).toList();
      state = state.copyWith(strokes: newStrokes, redoStack: []);
      _markDirty();
    }
  }

  // ─────────────── Pointer / Select ───────────────

  void _hitTestStroke(Offset position) {
    String? bestId;
    double bestDist = double.infinity;
    const threshold = AppDimensions.strokeHitTestThreshold *
        AppDimensions.strokeHitTestThreshold;

    for (final stroke in state.strokes) {
      for (final point in stroke.points) {
        final dx = point.x - position.dx;
        final dy = point.y - position.dy;
        final dist = dx * dx + dy * dy;
        if (dist < bestDist) {
          bestDist = dist;
          bestId = stroke.id;
        }
      }
    }

    if (bestDist <= threshold && bestId != null) {
      state = state.copyWith(selectedStrokeIds: {bestId});
    } else {
      state = state.copyWith(selectedStrokeIds: {});
    }
  }

  void deleteSelectedStroke() => deleteSelectedStrokes();

  void deleteSelectedStrokes() {
    if (!state.hasSelection) return;
    _pushUndoState();
    final newStrokes = state.strokes
        .where((s) => !state.selectedStrokeIds.contains(s.id))
        .toList();
    final newTexts = state.textElements
        .where((t) => !state.selectedTextIds.contains(t.id))
        .toList();
    state = state.copyWith(
      strokes: newStrokes,
      textElements: newTexts,
      selectedStrokeIds: {},
      selectedTextIds: {},
      selectionLassoPoints: () => null,
      selectionRect: () => null,
      activeTextId: () => null,
      redoStack: [],
    );
    _markDirty();
  }

  // ─────────────── Lasso / Box selection ───────────────

  void _startSelection(Offset position) {
    if (state.selectionMode == SelectionMode.freeform) {
      state = state.copyWith(
        selectionLassoPoints: () => [position],
        selectionRect: () => null,
        selectedStrokeIds: {},
        selectedTextIds: {},
        isSelecting: true,
      );
    } else {
      state = state.copyWith(
        selectionRect: () => Rect.fromPoints(position, position),
        selectionLassoPoints: () => null,
        selectedStrokeIds: {},
        selectedTextIds: {},
        isSelecting: true,
      );
    }
  }

  void _updateSelection(Offset position) {
    if (state.selectionMode == SelectionMode.freeform) {
      final points = <Offset>[...(state.selectionLassoPoints ?? []), position];
      state = state.copyWith(selectionLassoPoints: () => points);
    } else {
      final startPoint = state.selectionRect?.topLeft ?? position;
      state = state.copyWith(
        selectionRect: () => Rect.fromPoints(startPoint, position),
      );
    }
  }

  void _finalizeSelection() {
    final selectedIds = <String>{};
    final selectedTexts = <String>{};

    if (state.selectionMode == SelectionMode.freeform) {
      final lassoPoints = state.selectionLassoPoints;
      if (lassoPoints == null || lassoPoints.length < 3) {
        state = state.copyWith(
          isSelecting: false,
          selectionLassoPoints: () => null,
        );
        return;
      }

      final path = Path();
      path.moveTo(lassoPoints[0].dx, lassoPoints[0].dy);
      for (var i = 1; i < lassoPoints.length; i++) {
        path.lineTo(lassoPoints[i].dx, lassoPoints[i].dy);
      }
      path.close();

      for (final stroke in state.strokes) {
        for (final point in stroke.points) {
          if (path.contains(Offset(point.x, point.y))) {
            selectedIds.add(stroke.id);
            break;
          }
        }
      }

      // Also check text elements — use the actual rendered height so that
      // multi-line boxes are fully captured by the lasso.
      for (final el in state.textElements) {
        final elHeight = estimateTextBoxHeight(el);
        final topLeft = Offset(el.x, el.y);
        final center = Offset(el.x + el.width / 2, el.y + elHeight / 2);
        if (path.contains(topLeft) || path.contains(center)) {
          selectedTexts.add(el.id);
        }
      }
    } else {
      final rect = state.selectionRect;
      if (rect == null || rect.width.abs() < 5 || rect.height.abs() < 5) {
        state = state.copyWith(
          isSelecting: false,
          selectionRect: () => null,
        );
        return;
      }

      final normalizedRect = Rect.fromLTRB(
        rect.left < rect.right ? rect.left : rect.right,
        rect.top < rect.bottom ? rect.top : rect.bottom,
        rect.left < rect.right ? rect.right : rect.left,
        rect.top < rect.bottom ? rect.bottom : rect.top,
      );

      for (final stroke in state.strokes) {
        for (final point in stroke.points) {
          if (normalizedRect.contains(Offset(point.x, point.y))) {
            selectedIds.add(stroke.id);
            break;
          }
        }
      }

      // Also check text elements using the actual rendered height.
      for (final el in state.textElements) {
        final textRect =
            Rect.fromLTWH(el.x, el.y, el.width, estimateTextBoxHeight(el));
        if (normalizedRect.overlaps(textRect)) {
          selectedTexts.add(el.id);
        }
      }
    }

    state = state.copyWith(
      selectedStrokeIds: selectedIds,
      selectedTextIds: selectedTexts,
      isSelecting: false,
    );
  }

  void clearSelection() {
    state = state.copyWith(
      selectedStrokeIds: {},
      selectedTextIds: {},
      selectionLassoPoints: () => null,
      selectionRect: () => null,
      isSelecting: false,
    );
  }

  // ─────────────── Move selection ───────────────

  /// Snapshot undo state before a drag-move starts (called once per drag).
  void pushUndoForMoveSnapshot() {
    _pushUndoState();
  }

  /// Apply an incremental [delta] to all selected strokes and text elements.
  void moveSelectedByDelta(Offset delta) {
    if (!state.hasSelection) return;

    final movedStrokes = state.strokes.map((stroke) {
      if (!state.selectedStrokeIds.contains(stroke.id)) return stroke;
      final movedPoints = stroke.points
          .map((p) => StrokePoint(
                x: p.x + delta.dx,
                y: p.y + delta.dy,
                pressure: p.pressure,
                timestamp: p.timestamp,
              ))
          .toList();
      return Stroke(
        id: stroke.id,
        pageId: stroke.pageId,
        toolType: stroke.toolType,
        color: stroke.color,
        strokeWidth: stroke.strokeWidth,
        points: movedPoints,
        createdAt: stroke.createdAt,
        penStyle: stroke.penStyle,
      );
    }).toList();

    final movedTexts = state.textElements.map((el) {
      if (!state.selectedTextIds.contains(el.id)) return el;
      return el.copyWith(x: el.x + delta.dx, y: el.y + delta.dy);
    }).toList();

    state = state.copyWith(
      strokes: movedStrokes,
      textElements: movedTexts,
    );
  }

  /// Call after a drag-move finishes to persist the new positions.
  void finalizeSelectionMove() {
    _markDirty();
  }

  // ─────────────── Undo / Redo ───────────────

  void _pushUndoState() {
    var undoStack = [
      ...state.undoStack,
      (List<Stroke>.from(state.strokes), List<TextElement>.from(state.textElements)),
    ];
    if (undoStack.length > AppDimensions.maxUndoSteps) {
      undoStack = undoStack.sublist(undoStack.length - AppDimensions.maxUndoSteps);
    }
    state = state.copyWith(undoStack: undoStack);
  }

  void undo() {
    if (!state.canUndo) return;

    final undoStack = [...state.undoStack];
    final (prevStrokes, prevTexts) = undoStack.removeLast();
    final redoStack = [
      ...state.redoStack,
      (List<Stroke>.from(state.strokes), List<TextElement>.from(state.textElements)),
    ];

    state = state.copyWith(
      strokes: prevStrokes,
      textElements: prevTexts,
      undoStack: undoStack,
      redoStack: redoStack,
    );
    _markDirty();
  }

  void redo() {
    if (!state.canRedo) return;

    final redoStack = [...state.redoStack];
    final (nextStrokes, nextTexts) = redoStack.removeLast();
    final undoStack = [
      ...state.undoStack,
      (List<Stroke>.from(state.strokes), List<TextElement>.from(state.textElements)),
    ];

    state = state.copyWith(
      strokes: nextStrokes,
      textElements: nextTexts,
      undoStack: undoStack,
      redoStack: redoStack,
    );
    _markDirty();
  }

  // ─────────────── Clear page ───────────────

  void clearPage() {
    if (state.strokes.isEmpty) return;
    _pushUndoState();
    state = state.copyWith(strokes: [], redoStack: []);
    _markDirty();
  }

  // ─────────────── Text elements ───────────────

  void addTextElement(TextElement element) {
    _pushUndoState();
    final updated = [...state.textElements, element];
    state = state.copyWith(
      textElements: updated,
      activeTextId: () => element.id,
      redoStack: [],
    );
    _markDirty();
  }

  void updateTextElement(TextElement element) {
    final updated = state.textElements
        .map((e) => e.id == element.id ? element : e)
        .toList();
    state = state.copyWith(textElements: updated);
    _markDirty();
  }

  void deleteTextElement(String id) {
    _pushUndoState();
    final updated = state.textElements.where((e) => e.id != id).toList();
    state = state.copyWith(
      textElements: updated,
      activeTextId: () => null,
      redoStack: [],
    );
    _markDirty();
  }

  void setActiveText(String? id) {
    // Push undo when activating an existing text element so that typing
    // changes can be undone in a single step.
    if (id != null) {
      _pushUndoState();
    }
    state = state.copyWith(activeTextId: () => id);
  }

  // ─────────────── Copy / Paste ───────────────

  /// Pastes [strokes] and [textElements] from the clipboard onto this page.
  ///
  /// Each element receives a fresh ID and its [pageId] is set to [pageId] so
  /// it belongs to this page. All pasted content is offset by [pasteOffset]
  /// points so it doesn't land directly on top of the original.
  void pasteFromClipboard(
    List<Stroke> strokes,
    List<TextElement> textElements, {
    double pasteOffset = AppDimensions.pasteOffset,
  }) {
    if (strokes.isEmpty && textElements.isEmpty) return;

    _pushUndoState();

    final newStrokes = strokes.map((s) {
      final movedPoints = s.points
          .map((p) => StrokePoint(
                x: p.x + pasteOffset,
                y: p.y + pasteOffset,
                pressure: p.pressure,
                timestamp: p.timestamp,
              ))
          .toList();
      return Stroke(
        id: const Uuid().v4(),
        pageId: pageId,
        toolType: s.toolType,
        color: s.color,
        strokeWidth: s.strokeWidth,
        points: movedPoints,
        createdAt: DateTime.now(),
        penStyle: s.penStyle,
      );
    }).toList();

    final newTexts = textElements.map((t) {
      return t.copyWith(
        id: const Uuid().v4(),
        pageId: pageId,
        x: t.x + pasteOffset,
        y: t.y + pasteOffset,
      );
    }).toList();

    state = state.copyWith(
      strokes: [...state.strokes, ...newStrokes],
      textElements: [...state.textElements, ...newTexts],
      selectedStrokeIds: {for (final s in newStrokes) s.id},
      selectedTextIds: {for (final t in newTexts) t.id},
      redoStack: [],
    );
    _markDirty();
  }

  // ─────────────── Cancel gesture ───────────────

  /// Abort any in-progress stroke or lasso gesture. Called when a second
  /// finger lands on the canvas so that a pinch-to-zoom can take over without
  /// leaving a dangling half-drawn stroke or incomplete lasso region.
  void cancelActiveGesture() {
    if (state.activeStroke == null && !state.isSelecting) return;
    state = state.copyWith(
      activeStroke: () => null,
      isSelecting: false,
      selectionLassoPoints: () => null,
      selectionRect: () => null,
    );
  }

  // ─────────────── Zoom / Pan ───────────────

  void setZoom(double zoom) {
    state = state.copyWith(
      zoom: zoom.clamp(
        AppDimensions.canvasMinZoom,
        AppDimensions.canvasMaxZoom,
      ),
    );
  }

  void setCanvasOffset(Offset offset) {
    state = state.copyWith(canvasOffset: offset);
  }

  // ─────────────── Auto-save ───────────────

  void _markDirty() {
    _needsSave = true;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(
      const Duration(milliseconds: AppDimensions.autoSaveDelayMs),
      _saveToDb,
    );
  }

  Future<void> _saveToDb() async {
    if (!_needsSave) return;
    _needsSave = false;

    await _strokeDao.deleteByPageId(pageId);
    if (state.strokes.isNotEmpty) {
      await _strokeDao.insertBatch(state.strokes);
    }

    await _textDao.deleteByPageId(pageId);
    if (state.textElements.isNotEmpty) {
      await _textDao.insertBatch(state.textElements);
    }
  }

  /// Force save (e.g., when navigating away).
  Future<void> forceSave() async {
    _autoSaveTimer?.cancel();
    _needsSave = true;
    await _saveToDb();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    if (_needsSave) {
      _saveToDb();
    }
    super.dispose();
  }
}

/// Family provider keyed by pageId.
final canvasProvider =
    StateNotifierProvider.family<CanvasNotifier, CanvasState, String>(
  (ref, pageId) => CanvasNotifier(pageId: pageId),
);
