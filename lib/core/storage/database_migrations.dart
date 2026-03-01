import 'package:sqflite/sqflite.dart';

/// Defines every incremental schema migration for the StudyNotebook database.
///
/// ## How to add a new migration
///
/// 1. Increment [currentVersion] by 1.
/// 2. Add a new entry to [_migrations] keyed by the new version number.
///    The value is a list of SQL statements that transform the schema from the
///    previous version to the new one.
/// 3. Update [DatabaseTables] so it reflects the fully-current schema
///    (used only for brand-new installs via `onCreate`).
///
/// The [run] method applies every migration between [oldVersion] and
/// [newVersion] in strict ascending order, so upgrades that skip multiple
/// versions (e.g. 1 → 4) are handled automatically.
///
/// ## Schema history
///
/// | Version | Changes |
/// |---------|---------|
/// | 1       | Initial schema: courses, notebooks, pages, strokes, text_elements, documents, ai_messages |
/// | 2       | `pages`: added `background_color TEXT DEFAULT '#FFFFFF'`, `line_spacing REAL DEFAULT 32.0` |
/// | 3       | `strokes`: added `pen_style TEXT DEFAULT 'standard'` |
class DatabaseMigrations {
  DatabaseMigrations._();

  /// The current schema version.  Bump this when adding a new migration.
  static const int currentVersion = 3;

  /// Map of target-version → ordered list of SQL statements to apply.
  ///
  /// Key N contains the statements that bring the schema *from version N-1*
  /// *to version N*.  Do not edit existing entries — only append new ones.
  static const Map<int, List<String>> _migrations = {
    2: [
      "ALTER TABLE pages ADD COLUMN background_color TEXT DEFAULT '#FFFFFF'",
      'ALTER TABLE pages ADD COLUMN line_spacing REAL DEFAULT 32.0',
    ],
    3: [
      "ALTER TABLE strokes ADD COLUMN pen_style TEXT DEFAULT 'standard'",
    ],
  };

  /// Runs all migrations needed to bring the database from [oldVersion] to
  /// [newVersion].
  ///
  /// Migrations are applied in strictly ascending version order. If a version
  /// has no entry in [_migrations] it is silently skipped (safe for gaps).
  static Future<void> run(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (int v = oldVersion + 1; v <= newVersion; v++) {
      final statements = _migrations[v];
      if (statements == null) continue;
      for (final sql in statements) {
        await db.execute(sql);
      }
    }
  }
}
