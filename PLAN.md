# StudyNotebook Implementation Plan

## Completed
- [x] Phase 1: Core infrastructure (theme, models, DB, auth, routing, API client)
- [x] Phase 2: Home/Library UI (courses CRUD, notebooks CRUD, library screen)

## Phase 3: Notebook Canvas & Drawing
- [x] 3.1 Canvas widget with CustomPainter stroke rendering (perfect_freehand)
- [x] 3.2 Toolbar (pen, highlighter, eraser, color picker, stroke width)
- [x] 3.3 Page management (multi-page, templates: blank/lined/grid/dotted)
- [x] 3.4 Undo/redo system
- [x] 3.5 Auto-save strokes to SQLite
- [x] 3.6 Notebook screen integrating canvas + toolbar + pages

## Phase 4: Document Upload & Viewer
- [ ] 4.1 Document upload UI + Supabase Storage integration
- [ ] 4.2 PDF viewer with pdfrx
- [ ] 4.3 Document list in course detail screen

## Phase 5: AI Assistant
- [ ] 5.1 AI chat panel UI (slide-out drawer)
- [ ] 5.2 Hint/Check/Solve mode selector
- [ ] 5.3 Canvas-to-image capture for Check mode
- [ ] 5.4 API integration for AI chat (backend calls)
- [ ] 5.5 Source reference display with page links

## Phase 6: Lecture Capture
- [ ] 6.1 Audio recorder UI
- [ ] 6.2 Transcription API integration
- [ ] 6.3 Structured notes generator

## Phase 7: Review & Study Tools
- [ ] 7.1 Flashcard generation + review UI
- [ ] 7.2 Practice question generation
- [ ] 7.3 Quiz UI

## Phase 8: Polish
- [ ] 8.1 Search functionality
- [ ] 8.2 Settings/profile screen
- [ ] 8.3 Cloud sync logic
- [ ] 8.4 Error handling & retry UI
