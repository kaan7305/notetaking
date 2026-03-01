# StudyNotebook — Task Backlog

## In Progress
- (none)

## High Priority

### Canvas / Drawing
- (none remaining at this priority)

### AI Assistant
- [ ] (none remaining at this priority)

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
- [x] 2026-03-01: All PLAN.md phases 1–8 implemented
- [x] 2026-03-01: Drag-to-move for selected strokes and text elements
- [x] 2026-03-01: Fix undo/redo to track text element changes (now saves both strokes + text in stack)
- [x] 2026-03-01: Canvas-to-image capture for AI Check/Solve mode (RepaintBoundary GlobalKey, base64 PNG passed to sendMessage)
- [x] 2026-03-01: Auto-scroll chat to latest message after AI response (ref.listen on isLoading)
- [x] 2026-03-01: Text element resize handle (drag grip at right edge of active text box to widen/narrow)
