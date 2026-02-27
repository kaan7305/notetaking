import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/features/notebook/canvas/canvas_state.dart';

void main() {
  group('CanvasState', () {
    test('default values', () {
      const state = CanvasState();
      expect(state.strokes, isEmpty);
      expect(state.activeStroke, isNull);
      expect(state.currentTool, ToolType.pen);
      expect(state.currentColor, const Color(0xFF000000));
      expect(state.strokeWidth, 2.0);
      expect(state.highlighterWidth, 20.0);
      expect(state.canUndo, false);
      expect(state.canRedo, false);
      expect(state.zoom, 1.0);
    });

    test('activeStrokeWidth returns pen width for pen tool', () {
      const state = CanvasState(currentTool: ToolType.pen, strokeWidth: 5.0);
      expect(state.activeStrokeWidth, 5.0);
    });

    test('activeStrokeWidth returns highlighter width for highlighter tool', () {
      const state = CanvasState(
        currentTool: ToolType.highlighter,
        highlighterWidth: 25.0,
      );
      expect(state.activeStrokeWidth, 25.0);
    });

    test('activeStrokeWidth returns 20.0 for eraser', () {
      const state = CanvasState(currentTool: ToolType.eraser);
      expect(state.activeStrokeWidth, 20.0);
    });

    test('canUndo is true when undo stack is not empty', () {
      final state = CanvasState(undoStack: [[]]);
      expect(state.canUndo, true);
    });

    test('canRedo is true when redo stack is not empty', () {
      final state = CanvasState(redoStack: [[]]);
      expect(state.canRedo, true);
    });

    test('copyWith preserves unchanged fields', () {
      const state = CanvasState(strokeWidth: 3.0);
      final copy = state.copyWith(currentTool: ToolType.highlighter);
      expect(copy.strokeWidth, 3.0);
      expect(copy.currentTool, ToolType.highlighter);
    });

    test('copyWith can set activeStroke to null', () {
      final stroke = Stroke(
        id: 'test',
        pageId: 'p1',
        toolType: 'pen',
        color: '#FF000000',
        strokeWidth: 2.0,
        points: [],
        createdAt: DateTime.now(),
      );
      final state = CanvasState(activeStroke: stroke);
      final copy = state.copyWith(activeStroke: () => null);
      expect(copy.activeStroke, isNull);
    });
  });
}
