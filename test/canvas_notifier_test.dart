import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/storage/stroke_dao.dart';
import 'package:study_notebook/core/storage/text_element_dao.dart';
import 'package:study_notebook/features/notebook/canvas/canvas_notifier.dart';

class MockStrokeDao extends Mock implements StrokeDao {}

class MockTextElementDao extends Mock implements TextElementDao {}

void main() {
  late MockStrokeDao strokeDao;
  late MockTextElementDao textDao;

  setUp(() {
    strokeDao = MockStrokeDao();
    textDao = MockTextElementDao();

    // Stub all DAO methods used by CanvasNotifier.
    when(() => strokeDao.getByPageId(any()))
        .thenAnswer((_) async => const Success(<Stroke>[]));
    when(() => textDao.getByPageId(any()))
        .thenAnswer((_) async => const Success(<TextElement>[]));
    when(() => strokeDao.deleteByPageId(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => strokeDao.insertBatch(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => textDao.deleteByPageId(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => textDao.insertBatch(any()))
        .thenAnswer((_) async => const Success(null));
  });

  CanvasNotifier makeNotifier() => CanvasNotifier(
        pageId: 'test-page',
        strokeDao: strokeDao,
        textDao: textDao,
      );

  // Wait for the async _loadAll() in the notifier constructor.
  Future<void> pump() => Future.microtask(() {});

  group('CanvasNotifier.moveSelectedByDelta', () {
    test('moves selected strokes by the given delta', () async {
      final notifier = makeNotifier();
      await pump();

      // Draw a stroke.
      notifier.onPointerDown(const Offset(100, 100), 0.5);
      notifier.onPointerMove(const Offset(150, 150), 0.5);
      notifier.onPointerMove(const Offset(200, 200), 0.5);
      notifier.onPointerUp();

      expect(notifier.state.strokes, hasLength(1));

      // Switch to lasso / box mode and select the stroke.
      notifier.selectTool(ToolType.lasso);
      notifier.setSelectionMode(SelectionMode.box);
      notifier.onPointerDown(const Offset(50, 50), 0.5);
      notifier.onPointerMove(const Offset(250, 250), 0.5);
      notifier.onPointerUp();

      expect(notifier.state.selectedStrokeIds, isNotEmpty);

      final originalPoints = List.of(notifier.state.strokes.first.points);

      // Move the selection by (100, 50).
      notifier.moveSelectedByDelta(const Offset(100, 50));

      final movedPoints = notifier.state.strokes.first.points;
      for (var i = 0; i < originalPoints.length; i++) {
        expect(movedPoints[i].x, closeTo(originalPoints[i].x + 100, 0.001));
        expect(movedPoints[i].y, closeTo(originalPoints[i].y + 50, 0.001));
        // Pressure should be unchanged.
        expect(movedPoints[i].pressure, originalPoints[i].pressure);
      }
    });

    test('does not move unselected strokes', () async {
      final notifier = makeNotifier();
      await pump();

      // Draw two strokes.
      notifier.onPointerDown(const Offset(100, 100), 0.5);
      notifier.onPointerMove(const Offset(120, 120), 0.5);
      notifier.onPointerUp();

      notifier.onPointerDown(const Offset(300, 300), 0.5);
      notifier.onPointerMove(const Offset(320, 320), 0.5);
      notifier.onPointerUp();

      expect(notifier.state.strokes, hasLength(2));

      // Select only the first stroke (small box around it).
      notifier.selectTool(ToolType.lasso);
      notifier.setSelectionMode(SelectionMode.box);
      notifier.onPointerDown(const Offset(80, 80), 0.5);
      notifier.onPointerMove(const Offset(150, 150), 0.5);
      notifier.onPointerUp();

      expect(notifier.state.selectedStrokeIds, hasLength(1));

      final unselectedId = notifier.state.strokes
          .firstWhere((s) => !notifier.state.selectedStrokeIds.contains(s.id))
          .id;
      final unselectedPointsBefore = List.of(notifier.state.strokes
          .firstWhere((s) => s.id == unselectedId)
          .points);

      notifier.moveSelectedByDelta(const Offset(200, 200));

      final unselectedPointsAfter = notifier.state.strokes
          .firstWhere((s) => s.id == unselectedId)
          .points;

      // The unselected stroke should not have moved.
      for (var i = 0; i < unselectedPointsBefore.length; i++) {
        expect(
            unselectedPointsAfter[i].x, unselectedPointsBefore[i].x);
        expect(
            unselectedPointsAfter[i].y, unselectedPointsBefore[i].y);
      }
    });

    test('moves selected text elements by the given delta', () async {
      final notifier = makeNotifier();
      await pump();

      // Add a text element.
      final el = TextElement(
        id: 'text-1',
        pageId: 'test-page',
        content: 'Hello',
        x: 100,
        y: 200,
        width: 150,
        fontSize: 16,
        fontFamily: 'system',
        color: '#FF000000',
        createdAt: DateTime.now(),
      );
      notifier.addTextElement(el);
      notifier.setActiveText(null);

      // Manually select the text element by simulating lasso selection.
      notifier.selectTool(ToolType.lasso);
      notifier.setSelectionMode(SelectionMode.box);
      notifier.onPointerDown(const Offset(80, 180), 0.5);
      notifier.onPointerMove(const Offset(300, 240), 0.5);
      notifier.onPointerUp();

      expect(notifier.state.selectedTextIds, contains('text-1'));

      notifier.moveSelectedByDelta(const Offset(50, 30));

      final moved = notifier.state.textElements.first;
      expect(moved.x, closeTo(150, 0.001));
      expect(moved.y, closeTo(230, 0.001));
    });

    test('no-op when nothing is selected', () async {
      final notifier = makeNotifier();
      await pump();

      notifier.onPointerDown(const Offset(100, 100), 0.5);
      notifier.onPointerMove(const Offset(200, 200), 0.5);
      notifier.onPointerUp();

      final strokesBefore = List.of(notifier.state.strokes);

      // No selection — move should be a no-op.
      notifier.moveSelectedByDelta(const Offset(100, 100));

      expect(notifier.state.strokes.first.points.first.x,
          strokesBefore.first.points.first.x);
    });

    test('undo restores stroke positions after move', () async {
      final notifier = makeNotifier();
      await pump();

      notifier.onPointerDown(const Offset(100, 100), 0.5);
      notifier.onPointerMove(const Offset(150, 150), 0.5);
      notifier.onPointerUp();

      notifier.selectTool(ToolType.lasso);
      notifier.setSelectionMode(SelectionMode.box);
      notifier.onPointerDown(const Offset(50, 50), 0.5);
      notifier.onPointerMove(const Offset(200, 200), 0.5);
      notifier.onPointerUp();

      final originalX = notifier.state.strokes.first.points.first.x;

      notifier.pushUndoForMoveSnapshot();
      notifier.moveSelectedByDelta(const Offset(100, 0));

      expect(notifier.state.strokes.first.points.first.x,
          closeTo(originalX + 100, 0.001));

      notifier.undo();

      expect(notifier.state.strokes.first.points.first.x,
          closeTo(originalX, 0.001));
    });
  });

  group('CanvasNotifier text element undo/redo', () {
    TextElement makeText({String id = 'txt-1', String content = 'Hello'}) =>
        TextElement(
          id: id,
          pageId: 'test-page',
          content: content,
          x: 50,
          y: 50,
          width: 200,
          fontSize: 16,
          fontFamily: 'system',
          color: '#FF000000',
          createdAt: DateTime.now(),
        );

    test('undo after addTextElement removes the element', () async {
      final notifier = makeNotifier();
      await pump();

      notifier.addTextElement(makeText());
      expect(notifier.state.textElements, hasLength(1));

      notifier.undo();
      expect(notifier.state.textElements, isEmpty);
    });

    test('undo after deleteTextElement restores the element', () async {
      final notifier = makeNotifier();
      await pump();

      notifier.addTextElement(makeText());
      // Clear the undo from add so we can isolate the delete undo.
      notifier.addTextElement(makeText(id: 'txt-2', content: 'World'));
      // Undo the second add, leaving only txt-1.
      notifier.undo();
      expect(notifier.state.textElements, hasLength(1));

      notifier.deleteTextElement('txt-1');
      expect(notifier.state.textElements, isEmpty);

      notifier.undo();
      expect(notifier.state.textElements, hasLength(1));
      expect(notifier.state.textElements.first.id, 'txt-1');
    });

    test('undo after setActiveText + updateTextElement reverts content',
        () async {
      final notifier = makeNotifier();
      await pump();

      // Add a text element (pushes undo #1).
      notifier.addTextElement(makeText(content: 'Original'));
      // Undo the add, then redo to get it back — just to clear redo stack.
      // Actually, let's use it directly. Activate to start editing (pushes undo #2).
      notifier.setActiveText('txt-1');
      // Simulate typing.
      notifier.updateTextElement(makeText(content: 'Changed'));
      notifier.setActiveText(null);

      expect(notifier.state.textElements.first.content, 'Changed');

      // One undo step should revert to 'Original' (the snapshot taken when
      // setActiveText was called).
      notifier.undo();
      expect(notifier.state.textElements.first.content, 'Original');
    });

    test('redo after undo of addTextElement restores element', () async {
      final notifier = makeNotifier();
      await pump();

      notifier.addTextElement(makeText());
      notifier.undo();
      expect(notifier.state.textElements, isEmpty);

      notifier.redo();
      expect(notifier.state.textElements, hasLength(1));
    });
  });
}
