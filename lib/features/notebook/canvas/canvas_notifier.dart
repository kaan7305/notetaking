import 'dart:async';

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

    state = state.copyWith(strokes: strokes, textElements: texts);
  }

  // ─────────────── Tool selection ───────────────

  void selectTool(ToolType tool) {
    state = state.copyWith(
      currentTool: tool,
      selectedStrokeId: () => null,
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

  // ─────────────── Drawing ───────────────

  void onPointerDown(Offset position, double pressure) {
    if (state.currentTool == ToolType.pointer) {
      _hitTestStroke(position);
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
    );

    state = state.copyWith(activeStroke: () => stroke);
  }

  void onPointerMove(Offset position, double pressure) {
    if (state.currentTool == ToolType.eraser) {
      _eraseAt(position);
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
    );

    state = state.copyWith(activeStroke: () => updated);
  }

  void onPointerUp() {
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
    const threshold = 20.0 * 20.0;

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

    final newId = bestDist <= threshold ? bestId : null;
    state = state.copyWith(selectedStrokeId: () => newId);
  }

  void deleteSelectedStroke() {
    final id = state.selectedStrokeId;
    if (id == null) return;
    _pushUndoState();
    final newStrokes = state.strokes.where((s) => s.id != id).toList();
    state = state.copyWith(
      strokes: newStrokes,
      selectedStrokeId: () => null,
      redoStack: [],
    );
    _markDirty();
  }

  // ─────────────── Undo / Redo ───────────────

  void _pushUndoState() {
    var undoStack = [...state.undoStack, List<Stroke>.from(state.strokes)];
    if (undoStack.length > AppDimensions.maxUndoSteps) {
      undoStack = undoStack.sublist(undoStack.length - AppDimensions.maxUndoSteps);
    }
    state = state.copyWith(undoStack: undoStack);
  }

  void undo() {
    if (!state.canUndo) return;

    final undoStack = List<List<Stroke>>.from(state.undoStack);
    final previous = undoStack.removeLast();
    final redoStack = [
      ...state.redoStack,
      List<Stroke>.from(state.strokes)
    ];

    state = state.copyWith(
      strokes: previous,
      undoStack: undoStack,
      redoStack: redoStack,
    );
    _markDirty();
  }

  void redo() {
    if (!state.canRedo) return;

    final redoStack = List<List<Stroke>>.from(state.redoStack);
    final next = redoStack.removeLast();
    final undoStack = [
      ...state.undoStack,
      List<Stroke>.from(state.strokes)
    ];

    state = state.copyWith(
      strokes: next,
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
    final updated = [...state.textElements, element];
    state = state.copyWith(
      textElements: updated,
      activeTextId: () => element.id,
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
    final updated = state.textElements.where((e) => e.id != id).toList();
    state = state.copyWith(textElements: updated, activeTextId: () => null);
    _markDirty();
  }

  void setActiveText(String? id) {
    state = state.copyWith(activeTextId: () => id);
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
