import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_tables.dart';

/// Singleton helper that manages the SQLite database lifecycle.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Returns the open database, initializing it on the first call.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final path = '${documentsDir.path}/study_notebook.db';

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    for (final statement in DatabaseTables.allCreateStatements) {
      await db.execute(statement);
    }
  }

  /// Closes the database connection.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
