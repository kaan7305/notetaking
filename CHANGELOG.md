
## 2026-03-01 (cycle 14)

### Added
- **Undo/redo count indicator in toolbar** (`notebook_toolbar.dart`):
  - Replaced the two compact `_ModernToolbarButton` undo/redo buttons with a new `_UndoRedoButton` widget.
  - Each button now shows a small bold count label (primary-coloured) beneath the icon indicating how many steps remain in the undo or redo stack.
  - A reserved `SizedBox(height: 10)` keeps the icon vertically stable when the count is zero, preventing layout shifts.
  - Tooltip text updates to include the step count when > 0 (e.g. "Undo (5)").
  - The count is capped at "99+" to avoid overflow on very long sessions.
  - Removed the now-unused `compact` parameter from `_ModernToolbarButton`.

## 2026-03-01 (cycle 22)

### Added
- **Page duplicate feature** (`page_provider.dart`, `page_sidebar.dart`):
  - New `PageNotifier.duplicatePage(sourcePageId)` method: inserts a copy of the source page immediately after it, renumbers all subsequent pages, then batch-copies all strokes and text elements to the new page using new UUIDs.
  - `PageNotifier` now receives `StrokeDao` and `TextElementDao` as constructor dependencies.
  - Long-pressing a page thumbnail in the sidebar now always shows a context menu (previously only shown when deletion was possible). The menu contains a **Duplicate Page** option (always visible) and a **Delete Page** option (only shown when there are more than one page).

## 2026-03-01 (cycle 21)

### Fixed / Improved
- **PDF upload file size validation** (`document_upload_sheet.dart`): `_pickAndUpload` now checks `file.size` immediately after the picker returns. If the file exceeds 50 MB (`50 * 1024 * 1024` bytes) an inline error is shown and the upload is aborted before any network call.
- **Robust hex color parsing** (`notebook_screen.dart`): `_hexToColor` is now wrapped in a `try/catch`. Malformed hex strings (wrong length, non-hex characters, etc.) silently fall back to `Colors.white` instead of throwing a `FormatException` that would crash the canvas view.
- **Responsive AI chat panel width** (`ai_chat_panel.dart`): The panel width is no longer a hard-coded 360 px. It is now computed as `(screenWidth * 0.4).clamp(300.0, 480.0)` via `MediaQuery`, so it adapts to different iPad/tablet screen sizes while staying within sane bounds.
- **Typing indicator dark-mode support** (`ai_chat_panel.dart`): `_TypingIndicator` now uses `Theme.of(context).colorScheme.surfaceContainerHighest` for the bubble background and `colorScheme.onSurfaceVariant` for the spinner and text colour, replacing the hard-coded `Colors.grey.shade200` / `shade500` / `shade600` values that looked wrong in dark mode.

## 2026-03-01 (cycle 12)

### Added
- **Retry button for failed AI chat requests** (`ai_provider.dart`, `ai_chat_panel.dart`):
  - `AiChatState` now stores `retryContent` and `retryImageBase64` — the payload of the last failed message.
  - New `AiChatNotifier.retry()` method re-fires the API request without adding a duplicate user message.
  - `_dispatchRequest()` private helper extracted so both `sendMessage()` and `retry()` share the same API/state logic.
  - `_ErrorBanner` widget gains an optional **Retry** button (shown only when retry data exists); dismiss-only behavior unchanged when there is nothing to retry.
  - `clearError()` now also wipes `retryContent`/`retryImageBase64` so stale retry state never persists.

### Fixed
- Removed unnecessary `?.` null-aware operators on `activeEl.isBold` / `activeEl.isItalic` in `notebook_toolbar.dart` (both are inside an `else` block that guarantees non-null).
- Removed unused `makeStroke` local helper from `canvas_notifier_test.dart`.

## 2026-03-01 (cycle 20)

### Added
- **Keyboard shortcuts for the canvas** (`drawing_canvas.dart`, `canvas_notifier.dart`):
  - `Delete` / `Backspace` — already worked; now handled in the unified shortcut block.
  - `Escape` — deactivates the active text box if one is open; otherwise clears the current selection.
  - `Cmd/Ctrl + Z` — undo; consumed even when there is nothing to undo so the browser/system undo doesn't interfere.
  - `Cmd/Ctrl + Shift + Z` / `Ctrl + Y` — redo.
  - `Cmd/Ctrl + A` — select all strokes and text elements on the page (calls new `CanvasNotifier.selectAll()`).
  - `Cmd/Ctrl + C` — copies the current selection to the in-memory canvas clipboard.
  - `Cmd/Ctrl + V` — pastes from the clipboard (offset by `AppDimensions.pasteOffset` as usual).
- **`CanvasNotifier.selectAll()`**: New method that selects every stroke and text element on the page in one call. No-op on an empty canvas.
- **2 new unit tests** in `test/canvas_notifier_test.dart` covering `selectAll` with content and with an empty canvas (45 tests total).

## 2026-03-01 (cycle 19)

### Fixed
- **Pencil / touch / mouse cursor differentiation** in `DrawingCanvas`:
  - Added `_activePointerKind` field, updated by `onPointerDown` / `onPointerMove` and cleared on `onPointerUp` / `onPointerCancel`.  This gives the *effective* input kind at every moment (even during a pressed drag), which is used alongside the existing `_lastHoverDeviceKind` (mouse-hover only) to decide cursor behavior.
  - `_isCursorPreviewKind(kind)` — new static helper that returns `true` only for `mouse` and `trackpad`; `touch` and `stylus` kinds return `false`.
  - Custom cursor-preview circle is now suppressed for touch (iPad finger) and stylus (Apple Pencil) input.  Previously the overlay could appear during a finger-draw because `onPointerMove` updated `_hoverPosition` for all pointer kinds while `_lastHoverDeviceKind` was stale from a prior mouse hover.
  - `_cursorForTool` now returns `MouseCursor.defer` for `touch` as well as `stylus` / `invertedStylus`, ensuring the OS does not render a Flutter-managed cursor on top of touch or pencil interactions.
  - On `onPointerDown`, if the incoming kind is not a cursor-preview kind (touch / stylus), `_hoverPosition` is immediately cleared so no stale circle appears from a previous mouse hover.
  - `MouseRegion.cursor` and the cursor-preview overlay condition both use `_activePointerKind ?? _lastHoverDeviceKind` (active press takes priority over last hover kind).
- **`PlatformDispatcher` undefined-identifier in `main.dart`**: Replaced `PlatformDispatcher.instance.onError` with `WidgetsBinding.instance.platformDispatcher.onError`, which avoids a missing `dart:ui` import and is the idiomatic Flutter approach when `WidgetsFlutterBinding` is already initialized.

## 2026-03-01 (cycle 18)

### Added
- **Structured error / event logging** (`AppLogger` in `lib/core/utils/app_logger.dart`):
  - Four log levels: `debug`, `info`, `warning`, `error`. In release builds only `warning` and `error` are emitted; `debug`/`info` are no-ops.
  - Each call accepts an optional `tag` (source location), `data` (extra payload), `error` object, and `StackTrace`. Stack traces are truncated to the first 10 frames to keep the output readable.
  - `AppLogger.onFlutterError` hooked into `FlutterError.onError` in `main.dart` — captures unhandled widget/framework exceptions and still delegates to Flutter's default error presenter so the standard debug error screen is preserved.
  - `AppLogger.onPlatformError` hooked into `WidgetsBinding.instance.platformDispatcher.onError` — captures unhandled async errors that escape the Flutter zone.
  - `ApiClient` (`lib/core/api/api_client.dart`) now calls `AppLogger.warning` for `SocketException` and `TimeoutException` on every verb (GET/POST/PUT/DELETE/upload), `AppLogger.error` for unexpected catch-all errors, and `AppLogger.error` / `AppLogger.warning` for non-2xx HTTP responses (401, 404, 5xx).
  - No new external dependencies required — uses `package:flutter/foundation.dart`'s `debugPrint`.

## 2026-03-01 (cycle 17)

### Improved
- **Stylus vs mouse cursor differentiation** (`drawing_canvas.dart`):
  - Tracks `PointerDeviceKind` from every `onPointerHover` event.
  - For Apple Pencil / inverted-stylus input the custom circular cursor-preview overlay is now suppressed — the OS-managed pencil-tip indicator already provides visual feedback and the old overlay was redundant/distracting.
  - `_cursorForTool` now accepts an optional `PointerDeviceKind` parameter. When stylus input is detected it returns `MouseCursor.defer` (hands cursor ownership back to the system) instead of forcing `SystemMouseCursors.none`.
  - Mouse/trackpad behaviour is unchanged: pen/highlighter tools still hide the OS cursor and show the filled-circle preview; eraser shows the circle outline; text shows the I-beam; pointer/lasso show the precise arrow.

## 2026-03-01 (cycle 16)

### Fixed
- **Multi-line text-box hit testing**: Text elements with multi-line content are now correctly captured by taps, lasso selection, and box selection. Previously a hard-coded height of 30–40 px was used for all text boxes regardless of their actual content. A new `estimateTextBoxHeight(TextElement)` helper (in `core/utils/constants.dart`) uses `TextPainter.layout()` to compute the real rendered height, accounting for word wrapping and the element's declared `width` and `fontSize`. The computed height (clamped to a minimum of `AppDimensions.textBoxMinHeight = 28 px`) is now used in:
  - `_handleTextTap` in `drawing_canvas.dart` — the tap hit-rect now covers the full text box height.
  - `_computeSelectionBounds` in `drawing_canvas.dart` — the dashed selection bounds rect and drag-move hit zone now extend to the bottom of the last line.
  - `_finalizeSelection` (both lasso and box paths) in `canvas_notifier.dart` — the hit-test rect / lasso centre point used to decide whether a text element is inside the selection now reflects the actual element height.

### Chores
- **Named constants for magic numbers** (`AppDimensions` in `core/utils/constants.dart`):
  - `textBoxDeleteButtonWidth = 28.0` — replaces literal `28` in text-box hit rect width.
  - `textBoxVerticalPadding = 12.0`, `textBoxMinHeight = 28.0` — used by `estimateTextBoxHeight`.
  - `textBoxDefaultWidth = 200.0` — replaces literal `200` when creating a new text element.
  - `selectionInflateHitTest = 12.0` — replaces literal `12` in drag-to-move inflate radius.
  - `strokeHitTestThreshold = 20.0` — replaces `20.0 * 20.0` constant for pointer-tool hit distance.
  - `pasteOffset = 24.0` — replaces the literal default argument in `pasteFromClipboard`.

## 2026-03-01 (cycle 15)

### Added
- **Selection bounds indicator**: After a lasso or box selection is finalised, a dashed blue rectangle is drawn around the entire bounding box of all selected strokes and text elements. The rect is inflated by 8 px for breathing room and decorated with white-filled, blue-bordered square handles at the four corners and four edge midpoints — giving the user a clear affordance that the content is selected and can be dragged or deleted. Implementation: new `_SelectionBoundsPainter` (`CustomPainter`) inserted into the canvas `Stack` between the text elements and the floating action menu. The painter uses `PathMetrics` to trace the rect path and alternates draw/skip segments (`_dashLength = 6 pt`, `_gapLength = 4 pt`). The overlay is conditionally present only when `hasSelection && !isSelecting`, so it never appears during an in-progress lasso draw or box drag.

## 2026-03-01 (cycle 14)

### Added
- **Animated selection action menu**: The floating "N selected / delete" pill that appears above lasso/box selections now fades and scales in/out instead of appearing instantaneously. `_SelectionActionMenu` was converted from a `StatelessWidget` to a `StatefulWidget` (`_SelectionActionMenuState`) with a 180 ms `AnimationController`. `FadeTransition` handles opacity and `ScaleTransition` (0.88 → 1.0, anchored at `Alignment.bottomCenter`) handles the pop-in effect. The widget is always kept in the `Stack` (rather than conditionally added/removed) so the exit animation can play; the last valid `selectionBounds` are cached in `_lastKnownBounds` so the menu fades out at its original position even after the canvas state clears the selection. `IgnorePointer` blocks ghost-clicks while the menu is invisible or fading out.

### Fixed
- **`connectivityStreamProvider` now emits the initial connection state**: On Android, `Connectivity().onConnectivityChanged` does not emit the current state at subscription time, so the offline banner would stay hidden until the next network change. Fixed by converting the provider to an `async*` generator that calls `checkConnectivity()` first and then `yield*`s the change stream — ensuring the banner is correct from the first frame.

### Chores
- Exported `connectivity_provider.dart` from the `providers.dart` barrel file.
- Marked "Connection/offline status indicator" and "Database schema versioning / migration strategy" done in `TODO.md` (implementations existed from prior cycles but were not reflected in the backlog).

## 2026-03-01 (cycle 13)

### Added
- **Database schema versioning / migration strategy**: Extracted all SQLite migration SQL out of `DatabaseHelper._onUpgrade` into a dedicated `DatabaseMigrations` class (`lib/core/storage/database_migrations.dart`). The class owns a `currentVersion` constant (currently 3) and a private `_migrations` map keyed by target version — each entry is an ordered list of SQL statements that bring the schema from the previous version to that version. `DatabaseHelper` now reads its `version:` argument from `DatabaseMigrations.currentVersion` and delegates `_onUpgrade` to `DatabaseMigrations.run()`, which iterates the map in ascending order so skipped-version upgrades (e.g. 1 → 4) are handled automatically. The file includes a "Schema history" table documenting what changed in every version. `DatabaseMigrations` is exported from the `storage.dart` barrel. Three new unit tests in `test/database_migrations_test.dart` verify the structural invariants (positive integer, ≥ 3, correct type).

## 2026-03-01 (cycle 12)

### Added
- **Connection/offline status indicator**: A global animated banner now appears at the top of every screen when the device has no internet connection. Implementation: `connectivity_plus` package added; `connectivityStreamProvider` (a `StreamProvider<List<ConnectivityResult>>`) streams OS-level network changes; `isOfflineProvider` derives a boolean that is `true` only when every interface returns `ConnectivityResult.none`. `OfflineBanner` (`lib/core/widgets/offline_banner.dart`) wraps the router child in a `Column` and uses `SizeTransition` + `AnimationController` to slide the amber banner in/out smoothly. It is wired into `MaterialApp.router`'s `builder` in `main.dart` so no per-screen boilerplate is needed. The banner is optimistic on startup (shows only after the first stream event) to avoid a false-offline flash at launch.

## 2026-03-01 (cycle 11)

### Fixed
- **Complete pinch-to-zoom while drawing**: `notebook_screen.dart` `_CanvasAreaState` was still setting `scaleEnabled: !isDrawingTool`, preventing zoom when a drawing tool was active. Changed to `scaleEnabled: true` so `InteractiveViewer` always handles 2-finger scale gestures. The multi-touch guard in `DrawingCanvas` (`_activePointerCount` + `cancelActiveGesture()`) that was already in place ensures a 2-finger pinch cancels any in-progress stroke cleanly.

## 2026-03-01 (cycle 10)

### Added
- **Pinch-to-zoom while drawing tool is active**: Two-finger pinch-to-zoom now works even when pen, highlighter, eraser, or lasso is the active tool. Previously `InteractiveViewer` had `scaleEnabled: !isDrawingTool`, which disabled zoom during drawing. The fix has three parts: (1) `scaleEnabled` in `_CanvasAreaState` is now unconditionally `true`; (2) `DrawingCanvas` tracks `_activePointerCount` via `onPointerDown`/`onPointerUp`/`onPointerCancel` and suppresses all drawing logic when >1 pointer is active; (3) a new `cancelActiveGesture()` method on `CanvasNotifier` clears any in-progress stroke or lasso selection when a second finger lands, so the pinch gesture starts cleanly without a dangling half-drawn stroke. Single-finger pan remains disabled while drawing tools are active.

## 2026-03-01 (cycle 9)

### Added
- **Page reorder via drag in sidebar**: The page sidebar (`PageSidebar`) now uses `ReorderableListView.builder` instead of `ListView.builder`. Each page thumbnail displays a `drag_handle_rounded` icon at the bottom-right, wrapped in `ReorderableDragStartListener`. Dragging the handle reorders pages by calling the existing `PageNotifier.reorderPage(pageId, newPosition)` method — which renumbers and persists all affected pages. The long-press context menu (delete) is preserved. `buildDefaultDragHandles: false` keeps the default handle hidden so only the explicit icon is draggable.

## 2026-03-01 (cycle 8)

### Added
- **Copy/paste selection across pages**: Tapping the **Copy** button in the selection toolbar stores the selected strokes and text elements in a new global `ClipboardProvider` (`clipboard_provider.dart`). The clipboard persists across page switches, so the content can be pasted onto any page. A **Paste** button appears in the selection toolbar whenever the clipboard is non-empty; tapping it calls `CanvasNotifier.pasteFromClipboard`, which clones each element with a fresh UUID, sets `pageId` to the current page, offsets coordinates by 24 pt so the paste is visually distinct, adds them to the canvas, selects all pasted elements, and triggers auto-save. Both buttons use the new `_IconActionButton` helper with tooltips. The selection count badge now reflects both stroke and text-element counts.

## 2026-03-01 (cycle 7)

### Added
- **Export page as PNG**: A new share button (`ios_share_rounded` icon) appears in the notebook toolbar between the undo/redo group and the AI panel toggle. Tapping it renders the current canvas at 2× pixel density via `RepaintBoundary.toImage`, writes the PNG bytes to a temp file, and invokes `Share.shareXFiles` from `share_plus` — giving the user the native iOS/Android share sheet to save or send the image. On error a red `SnackBar` is shown. The `_captureCanvas()` → `_exportPage()` pattern reuses the existing `GlobalKey` + `RepaintBoundary` already in place for AI Check/Solve mode. New constants: `AppStrings.exportPage`, `.exportPageSubject`, `.exportError`.

## 2026-03-01 (cycle 6)

### Improved
- **Text element resize handle — right-edge vertical bar**: Replaced the previous bottom-pill drag grip with a discoverable right-edge vertical drag strip (`_TextResizeHandle`). The handle is overlaid on the right side of the active text box using a `Stack(clipBehavior: Clip.none)` so it never clips. It animates from 3 px to 4 px wide on hover and uses `SystemMouseCursors.resizeColumn` for a natural desktop affordance. The `_TextBox` layout was restructured from `Expanded` (which leaked width through the parent `Positioned`) to a `SizedBox(width: el.width)` so the text area has an exact, model-driven width at all times, and the outer `Positioned` no longer needs an explicit `width` argument.

## 2026-03-01 (cycle 5)

### Fixed
- **DB load error feedback on canvas**: `CanvasState` now has a nullable `loadError` field. When `_loadAll()` in `CanvasNotifier` receives a `Failure` from either `StrokeDao` or `TextElementDao`, it stores the error message in state rather than silently continuing with empty lists. `DrawingCanvas` checks for `loadError != null` and overlays a slim red dismissible banner at the top of the canvas explaining that saved content could not be loaded (the canvas remains usable for new strokes drawn in the current session).

### Added
- **Name max-length validation** for course and notebook creation dialogs: `AppDimensions.maxNameLength = 100` and `AppStrings.nameTooLong` constants added. Both `CreateCourseDialog` and `CreateNotebookDialog` now pass `maxLength: 100` to their `TextField` widgets (showing a live character counter) and guard `_submit()` with a length check that surfaces a validation error before any DB call is made.

## 2026-03-01 (cycle 4)

### Added
- **Text element resize handle**: When a text box is active (selected for editing), a small blue drag grip appears below the right edge of the text field. Dragging it horizontally changes `TextElement.width`, clamped to 80–800 px. The change is auto-saved via the existing debounced save pipeline. The handle uses `SystemMouseCursors.resizeLeftRight` on desktop for a clear affordance.

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
