# StudyNotebook — AI-Powered Handwriting Notebook

## What this is
A handwriting notebook app (like Notability) for iPad and Android tablets with integrated AI tutoring. Students upload course documents, handwrite notes, and get AI assistance (hint/check/solve) that is grounded ONLY in their uploaded documents.

## Tech stack
- App: Flutter (Dart), targeting iOS (iPad) and Android tablets
- Drawing: `perfect_freehand` for stroke rendering, `pencilkit` for native iOS Apple Pencil
- State management: `flutter_riverpod`
- Local DB: `sqflite` for note storage, stroke data
- PDF rendering: `pdfrx`
- Audio recording: `record` package
- OCR: Google ML Kit `google_mlkit_digital_ink_recognition`
- Backend: Next.js API (adapted from PDR_AI_v2), deployed on Vercel
- Database: Supabase (PostgreSQL + pgvector)
- Storage: Supabase Storage (for PDFs, audio files)
- Auth: Supabase Auth
- AI: OpenAI API (GPT-4o for chat, Whisper for transcription)
- RAG: LangChain (already in PDR_AI_v2 backend)

## Project structure
```
lib/
  main.dart
  app/
    router.dart                — GoRouter navigation
    theme.dart                 — App theme + colors
  features/
    auth/                      — Login, registration, profile
    courses/                   — Course creation, management
    notebook/
      canvas/                  — Drawing canvas, stroke engine, tools
      pages/                   — Page management, templates
      toolbar/                 — Pen, eraser, highlighter, lasso, colors
    documents/
      upload/                  — Document upload UI
      viewer/                  — PDF viewer with highlighting
    ai_assistant/
      chat/                    — AI chat panel
      modes/                   — Hint, Check, Solve mode logic
      references/              — Page reference display
    lecture_capture/
      recorder/                — Audio recording
      transcription/           — Whisper API integration
      notes_generator/         — Structured notes from transcript
    review/
      flashcards/              — Flashcard generation + review
      practice/                — Practice question generation
      quiz/                    — Quiz UI
  core/
    api/                       — API client for backend calls
    models/                    — Data models (Course, Note, Document, etc.)
    providers/                 — Riverpod providers
    storage/                   — Local storage helpers
    utils/                     — Shared utilities
```

## Commands
- `flutter run` — run on connected device/simulator
- `flutter run -d chrome` — run on web (for quick testing)
- `flutter test` — run tests
- `flutter analyze` — static analysis
- `flutter build ios` — build for iOS
- `flutter build apk` — build for Android
- `dart format .` — format code

## Code conventions
- State management: Riverpod only (no setState for complex state)
- Navigation: GoRouter with typed routes
- File naming: snake_case for files, PascalCase for classes
- One widget per file for any widget over 50 lines
- All API calls go through `core/api/` — never call HTTP directly from widgets
- Models use `freezed` for immutability + JSON serialization
- Error handling: Result pattern (no throwing exceptions across layers)
- All strings that users see go in a constants file (for future i18n)

## CRITICAL: AI behavior rules
- AI responses MUST be grounded in uploaded documents only
- If the document doesn't contain relevant info, AI must say so
- Hint mode: Give a conceptual nudge, point to the relevant page, never give the answer
- Check mode: Evaluate the student's handwritten work, identify errors, explain what went wrong
- Solve mode: Full step-by-step solution with page references
- Every AI response must include source references (document name + page number)

## When making changes
- Always run `flutter analyze` after changes
- Always run `flutter test` after implementation
- Commit working code immediately
- Test on iPad simulator for any UI changes
- Canvas/drawing changes MUST be tested with Apple Pencil on a real iPad
