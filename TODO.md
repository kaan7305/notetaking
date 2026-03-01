# StudyNotebook — Task Backlog

## In Progress
- (none)

## High Priority

### Canvas / Drawing
- [ ] Text element resize handle (width is fixed, hard to widen text boxes)

### AI Assistant
- [ ] (none remaining at this priority)

### Stability / Correctness
- [ ] Add error feedback when DB load fails on canvas open (currently silent empty canvas)
- [ ] Validate notebook/course name max length before creating

## Medium Priority
- [ ] Move selected strokes across pages (copy/paste between pages)
- [ ] Export current page as PNG/PDF
- [ ] Pinch-to-zoom during drawing tool active (currently disabled)
- [ ] Page reorder via drag in sidebar
- [ ] Connection/offline status indicator
- [ ] Database schema versioning / migration strategy

## Low Priority / Polish
- [ ] Animate selection action menu (fade in/out)
- [ ] Selection bounds indicator (dashed rect around selected content)
- [ ] Pencil cursor on iPad vs mouse cursor on desktop differentiation
- [ ] Text box: multi-line height calculation for accurate hit testing
- [ ] Replace magic numbers with named constants (AppDimensions)
- [ ] Add analytics / error logging

## Completed
- [x] 2026-03-01: All PLAN.md phases 1–8 implemented
- [x] 2026-03-01: Drag-to-move for selected strokes and text elements
- [x] 2026-03-01: Fix undo/redo to track text element changes (now saves both strokes + text in stack)
- [x] 2026-03-01: Canvas-to-image capture for AI Check/Solve mode (RepaintBoundary GlobalKey, base64 PNG passed to sendMessage)
- [x] 2026-03-01: Auto-scroll chat to latest message after AI response (ref.listen on isLoading)
