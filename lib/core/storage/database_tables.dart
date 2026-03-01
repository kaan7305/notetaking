/// SQL CREATE TABLE and CREATE INDEX statements for the StudyNotebook database.
class DatabaseTables {
  DatabaseTables._();

  // ──────────────────────────────────────────────
  // CREATE TABLE statements
  // ──────────────────────────────────────────────

  static const String createCourses = '''
    CREATE TABLE courses (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      name TEXT NOT NULL,
      description TEXT,
      color TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      is_synced INTEGER DEFAULT 0
    )
  ''';

  static const String createNotebooks = '''
    CREATE TABLE notebooks (
      id TEXT PRIMARY KEY,
      course_id TEXT NOT NULL REFERENCES courses(id),
      user_id TEXT,
      title TEXT NOT NULL,
      cover_image_path TEXT,
      page_size TEXT DEFAULT 'letter',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      is_favorite INTEGER DEFAULT 0,
      is_synced INTEGER DEFAULT 0
    )
  ''';

  static const String createPages = '''
    CREATE TABLE pages (
      id TEXT PRIMARY KEY,
      notebook_id TEXT NOT NULL REFERENCES notebooks(id),
      page_number INTEGER NOT NULL,
      template_type TEXT DEFAULT 'blank',
      background_color TEXT DEFAULT '#FFFFFF',
      line_spacing REAL DEFAULT 32.0,
      thumbnail_path TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      is_synced INTEGER DEFAULT 0
    )
  ''';

  static const String createStrokes = '''
    CREATE TABLE strokes (
      id TEXT PRIMARY KEY,
      page_id TEXT NOT NULL REFERENCES pages(id),
      tool_type TEXT NOT NULL,
      color TEXT NOT NULL,
      stroke_width REAL NOT NULL,
      points TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      is_deleted INTEGER DEFAULT 0,
      pen_style TEXT DEFAULT 'standard'
    )
  ''';

  static const String createTextElements = '''
    CREATE TABLE text_elements (
      id TEXT PRIMARY KEY,
      page_id TEXT NOT NULL REFERENCES pages(id),
      content TEXT NOT NULL,
      x REAL NOT NULL,
      y REAL NOT NULL,
      width REAL NOT NULL,
      font_size REAL DEFAULT 16.0,
      font_family TEXT DEFAULT 'system',
      color TEXT DEFAULT '#000000',
      is_bold INTEGER DEFAULT 0,
      is_italic INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL,
      is_deleted INTEGER DEFAULT 0
    )
  ''';

  static const String createDocuments = '''
    CREATE TABLE documents (
      id TEXT PRIMARY KEY,
      course_id TEXT NOT NULL REFERENCES courses(id),
      user_id TEXT,
      file_name TEXT NOT NULL,
      storage_path TEXT NOT NULL,
      local_path TEXT,
      page_count INTEGER DEFAULT 0,
      status TEXT DEFAULT 'uploading',
      created_at INTEGER NOT NULL,
      is_synced INTEGER DEFAULT 0
    )
  ''';

  static const String createAiMessages = '''
    CREATE TABLE ai_messages (
      id TEXT PRIMARY KEY,
      course_id TEXT NOT NULL,
      role TEXT NOT NULL,
      content TEXT NOT NULL,
      image_base64 TEXT,
      mode TEXT NOT NULL,
      references_json TEXT,
      created_at INTEGER NOT NULL
    )
  ''';

  static const String createFlashcards = '''
    CREATE TABLE flashcards (
      id TEXT PRIMARY KEY,
      course_id TEXT NOT NULL REFERENCES courses(id),
      sort_order INTEGER NOT NULL,
      front TEXT NOT NULL,
      back TEXT NOT NULL,
      source_document TEXT,
      source_page INTEGER,
      created_at INTEGER NOT NULL
    )
  ''';

  // ──────────────────────────────────────────────
  // CREATE INDEX statements
  // ──────────────────────────────────────────────

  static const String indexNotebooksCourseId = '''
    CREATE INDEX idx_notebooks_course_id ON notebooks(course_id)
  ''';

  static const String indexPagesNotebookId = '''
    CREATE INDEX idx_pages_notebook_id ON pages(notebook_id)
  ''';

  static const String indexStrokesPageId = '''
    CREATE INDEX idx_strokes_page_id ON strokes(page_id)
  ''';

  static const String indexTextElementsPageId = '''
    CREATE INDEX idx_text_elements_page_id ON text_elements(page_id)
  ''';

  static const String indexDocumentsCourseId = '''
    CREATE INDEX idx_documents_course_id ON documents(course_id)
  ''';

  static const String indexAiMessagesCourseId = '''
    CREATE INDEX idx_ai_messages_course_id ON ai_messages(course_id)
  ''';

  static const String indexFlashcardsCourseId = '''
    CREATE INDEX idx_flashcards_course_id ON flashcards(course_id)
  ''';

  static const String indexCoursesIsSynced = '''
    CREATE INDEX idx_courses_is_synced ON courses(is_synced)
  ''';

  static const String indexNotebooksIsSynced = '''
    CREATE INDEX idx_notebooks_is_synced ON notebooks(is_synced)
  ''';

  static const String indexPagesIsSynced = '''
    CREATE INDEX idx_pages_is_synced ON pages(is_synced)
  ''';

  static const String indexStrokesIsSynced = '''
    CREATE INDEX idx_strokes_is_deleted ON strokes(is_deleted)
  ''';

  static const String indexDocumentsIsSynced = '''
    CREATE INDEX idx_documents_is_synced ON documents(is_synced)
  ''';

  // ──────────────────────────────────────────────
  // All statements in dependency order
  // ──────────────────────────────────────────────

  static List<String> get allCreateStatements => [
        // Tables (order matters due to foreign keys)
        createCourses,
        createNotebooks,
        createPages,
        createStrokes,
        createTextElements,
        createDocuments,
        createAiMessages,
        createFlashcards,
        // Indexes
        indexNotebooksCourseId,
        indexPagesNotebookId,
        indexStrokesPageId,
        indexTextElementsPageId,
        indexDocumentsCourseId,
        indexAiMessagesCourseId,
        indexFlashcardsCourseId,
        indexCoursesIsSynced,
        indexNotebooksIsSynced,
        indexPagesIsSynced,
        indexStrokesIsSynced,
        indexDocumentsIsSynced,
      ];
}
