import 'package:sqflite/sqflite.dart';

import 'package:study_notebook/core/models/models.dart';

import 'database_helper.dart';

/// A single flashcard row as stored in SQLite.
class FlashcardRow {
  final String id;
  final String courseId;
  final int sortOrder;
  final String front;
  final String back;
  final String? sourceDocument;
  final int? sourcePage;
  final DateTime createdAt;

  const FlashcardRow({
    required this.id,
    required this.courseId,
    required this.sortOrder,
    required this.front,
    required this.back,
    this.sourceDocument,
    this.sourcePage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'course_id': courseId,
        'sort_order': sortOrder,
        'front': front,
        'back': back,
        'source_document': sourceDocument,
        'source_page': sourcePage,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  static FlashcardRow fromMap(Map<String, dynamic> m) => FlashcardRow(
        id: m['id'] as String,
        courseId: m['course_id'] as String,
        sortOrder: m['sort_order'] as int,
        front: m['front'] as String,
        back: m['back'] as String,
        sourceDocument: m['source_document'] as String?,
        sourcePage: m['source_page'] as int?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}

/// Data-access object for the `flashcards` table.
///
/// Generated card sets for a course are stored as an ordered list.
/// Calling [replaceByCourseId] atomically deletes the old set and
/// inserts the new one inside a transaction, so the UI never sees
/// a half-written state.
class FlashcardDao {
  final DatabaseHelper _dbHelper;

  FlashcardDao([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // ─────────────────────────── READ ────────────────────────────

  /// Returns all flashcards for [courseId], ordered by [sort_order] ASC.
  Future<Result<List<FlashcardRow>>> getByCourseId(String courseId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'flashcards',
        where: 'course_id = ?',
        whereArgs: [courseId],
        orderBy: 'sort_order ASC',
      );
      return Success(maps.map(FlashcardRow.fromMap).toList());
    } catch (e) {
      return Failure('Failed to load flashcards', e);
    }
  }

  // ─────────────────────────── WRITE ───────────────────────────

  /// Atomically replaces all flashcards for [courseId] with [rows].
  ///
  /// The delete + insert is wrapped in a transaction so the database
  /// is never in a partial state. Pass an empty list to clear without
  /// inserting.
  Future<Result<void>> replaceByCourseId(
    String courseId,
    List<FlashcardRow> rows,
  ) async {
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        await txn.delete(
          'flashcards',
          where: 'course_id = ?',
          whereArgs: [courseId],
        );
        for (final row in rows) {
          await txn.insert(
            'flashcards',
            row.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      return const Success(null);
    } catch (e) {
      return Failure('Failed to save flashcards', e);
    }
  }

  /// Deletes all flashcards for [courseId].
  Future<Result<void>> deleteAllByCourseId(String courseId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'flashcards',
        where: 'course_id = ?',
        whereArgs: [courseId],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete flashcards', e);
    }
  }
}
