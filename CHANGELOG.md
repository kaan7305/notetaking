
## 2026-03-01 (cycle 3)

### Added
- **Canvas-to-image capture for AI Check/Solve mode**: `DrawingCanvas` now accepts an optional `captureKey` (`GlobalKey`) that is attached to its inner `RepaintBoundary`. `NotebookScreen` holds a single `GlobalKey` and a `_captureCanvas()` method that renders the boundary to a 1.5× PNG and returns it as a base64 string. `AiChatPanel` receives a `captureCanvas` callback; when sending a message in **Check** or **Solve** mode it calls the callback and passes the resulting `imageBase64` to `sendMessage`. The `imageBase64` is already forwarded to the backend request body.
- **Auto-scroll to latest message after AI response**: Added a `ref.listen` on `aiChatProvider` in `AiChatPanel`. When `isLoading` transitions from `true` to `false` (AI response received), `_scrollToBottom()` is triggered automatically, so the user always sees the new reply without manually scrolling.

## 2026-03-01 (cycle 2)

### Fixed
- **Undo/redo now tracks text element changes**: The undo/redo stack previously only stored strokes, so adding, moving, or deleting text elements was invisible to undo history. The stack type changed from `List<List<Stroke>>` to `List<(List<Stroke>, List<TextElement>)>` (Dart 3 record tuples). `_pushUndoState`, `undo`, and `redo` all now snapshot and restore both strokes and text elements atomically.
- **Text element mutations are now undoable**: `addTextElement` and `deleteTextElement` push an undo snapshot before mutating. `setActiveText(id)` pushes a snapshot when an editing session begins so the entire typing session can be undone in one step.
- **4 new tests** in `test/canvas_notifier_test.dart` covering undo of text add, delete, content edit, and redo of text add.

## 2026-03-01

### Added
- **Drag-to-move for selected strokes and text elements**: Users can now drag selected content (lasso or box selection) to reposition it anywhere on the page. The selection action menu follows the selection during the drag. Undo support: one undo step is pushed at the start of each drag.
- **Drag-to-reposition text boxes**: When the text tool is active and a text box is not being edited, it can be dragged to a new position by panning on it.
- **`moveSelectedByDelta` and `pushUndoForMoveSnapshot` on `CanvasNotifier`**: New methods for incremental selection moves with proper undo integration.
- **5 new unit tests** in `test/canvas_notifier_test.dart` covering move semantics (selected strokes, unselected strokes, text elements, no-op, and undo).
- **`TODO.md`** created with prioritised backlog of remaining improvements.
