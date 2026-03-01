import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

/// Data-access object for the [preferences] key-value table.
///
/// Each row has a [key] (TEXT PRIMARY KEY) and a [value] (TEXT).
/// Use [get] / [set] / [remove] to read and write individual entries.
class PreferencesDao {
  final DatabaseHelper _dbHelper;

  const PreferencesDao(this._dbHelper);

  /// Returns the stored value for [key], or [defaultValue] when absent.
  Future<String> get(String key, {String defaultValue = ''}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'preferences',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return defaultValue;
    return rows.first['value'] as String? ?? defaultValue;
  }

  /// Inserts or replaces the value for [key].
  Future<void> set(String key, String value) async {
    final db = await _dbHelper.database;
    await db.insert(
      'preferences',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Deletes the row for [key].  No-op when the key does not exist.
  Future<void> remove(String key) async {
    final db = await _dbHelper.database;
    await db.delete('preferences', where: 'key = ?', whereArgs: [key]);
  }
}
