# StudyNotebook — Task Backlog

## In Progress
- (none)

## Completed (cycle 18)
- [x] 2026-03-01: Fix missing `package:flutter/services.dart` import in `flashcard_screen.dart` — `KeyDownEvent` and `LogicalKeyboardKey` were unresolved (14 analyzer errors); adding the import clears all of them
- [x] 2026-03-01: Quiz UX improvements — animated progress bar (`TweenAnimationBuilder<double>` + `LinearProgressIndicator`, 4 px, advances on answer reveal), per-score motivational message on completion screen (4 tiers: ≥90/≥70/≥50/<50), "New Questions" `OutlinedButton` on completion screen + matching AppBar icon button, "Regenerate" AppBar icon when quiz is complete

## Completed (cycle 19)
- [x] 2026-03-01: Quiz keyboard shortcuts — A/B/C/D select answer options, Space/Enter advances to next question; `_QuestionView` converted to `StatefulWidget` with `FocusNode` (auto-focused on mount); keyboard hint label below options switches text between "A / B / C / D to select" and "Space / Enter → Next Question"

## Potential future tasks
- [ ] Persist practice questions to SQLite between sessions (like flashcards)
- [ ] Add JSON parse safety (try/catch) around API response parsing in flashcard_provider and practice_provider
- [ ] Offline sync mechanism — implement `SyncProvider` that queues is_synced=0 rows and pushes to Supabase on reconnect
- [ ] Document viewer: highlight the snippet referenced by AI source citations

## Completed (cycle 17)
- [x] 2026-03-01: Swipe gestures + keyboard shortcuts for flashcard navigation — horizontal swipe (left=next, right=previous), arrow keys (←→) + Space/↑↓ to flip, auto-focus on mount, subtle navigation hint below card

## Completed (cycle 16)
- [x] 2026-03-01: Flashcard shuffle + reset — `FlashcardNotifier.shuffle()` (random reorder, jump to card 1), `FlashcardNotifier.reset()` now exposed via AppBar buttons; `_FlashcardView` rewritten as `StatefulWidget` with true 3D Y-axis flip animation (matrix perspective, 400 ms, easeIn/easeOut); card change (shuffle/nav) snaps to correct face without animation

## Medium Priority
- [x] 2026-03-01: Add retry button for failed AI chat requests
- [x] 2026-03-01: Validate PDF upload file size (warn if > 50 MB)
- [x] 2026-03-01: Robust hex color parsing in notebook_screen (guard against malformed values)
- [x] 2026-03-01: Responsive AI chat panel width (clamp to 40% of screen instead of fixed 360 px)

## Low Priority / Polish
- [x] 2026-03-01: Typing indicator dark-mode support (uses theme-aware colorScheme colors)
- [x] 2026-03-01: Undo/redo count indicator in toolbar (show remaining steps)
- [x] 2026-03-01: Page duplicate feature in sidebar long-press menu

## High Priority

### Canvas / Drawing
- (none remaining at this priority)

### AI Assistant
- [x] 2026-03-01: Persist AI chat history to SQLite (AiMessagesDao + isLoadingHistory state, 100-message prune limit, images excluded from DB)

### Stability / Correctness
- [x] 2026-03-01: Add error feedback when DB load fails on canvas open (dismissible red banner)
- [x] 2026-03-01: Validate notebook/course name max length before creating (100-char limit + counter)

## Medium Priority
- [x] 2026-03-01: Move selected strokes across pages (copy/paste between pages)
- [x] 2026-03-01: Export current page as PNG/PDF
- [x] 2026-03-01: Pinch-to-zoom during drawing tool active (currently disabled)
- [x] 2026-03-01: Page reorder via drag in sidebar
- [x] 2026-03-01: Connection/offline status indicator
- [x] 2026-03-01: Database schema versioning / migration strategy

## Low Priority / Polish
- [x] 2026-03-01: Animate selection action menu (fade in/out)
- [x] 2026-03-01: Selection bounds indicator (dashed rect around selected content)
- [x] 2026-03-01: Text box: multi-line height calculation for accurate hit testing
- [x] 2026-03-01: Replace magic numbers with named constants (AppDimensions)
- [x] 2026-03-01: Pencil cursor on iPad vs mouse cursor on desktop differentiation
- [x] 2026-03-01: Add analytics / error logging

## Completed
- [x] 2026-03-01: Page thumbnail text element rendering (page_sidebar.dart — _TextElementsThumbnailPainter renders typed text alongside strokes in the sidebar thumbnail)
- [x] 2026-03-01: Fix clearPage() to also clear text elements (was strokes-only — bug)
- [x] 2026-03-01: Fix deactivate() save guard (now saves first page even when _selectedPageId is null)
- [x] 2026-03-01: Defensive hex parsing in _PageThumbnail (page_sidebar.dart — same try/catch as notebook_screen.dart)
- [x] 2026-03-01: All PLAN.md phases 1–8 implemented
- [x] 2026-03-01: Drag-to-move for selected strokes and text elements
- [x] 2026-03-01: Fix undo/redo to track text element changes (now saves both strokes + text in stack)
- [x] 2026-03-01: Canvas-to-image capture for AI Check/Solve mode (RepaintBoundary GlobalKey, base64 PNG passed to sendMessage)
- [x] 2026-03-01: Auto-scroll chat to latest message after AI response (ref.listen on isLoading)
- [x] 2026-03-01: Text element resize handle (drag grip at right edge of active text box to widen/narrow)
