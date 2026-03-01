import 'package:sqflite/sqflite.dart';

import 'package:study_notebook/core/models/models.dart';

import 'database_helper.dart';

/// A single practice-question row as stored in SQLite.
class PracticeQuestionRow {
  final String id;
  final String courseId;
  final int sortOrder;
  final String question;
  final String optionsJson; // JSON array of strings
  final int correctIndex;
  final String explanation;
  final String? sourceDocument;
  final int? sourcePage;
  final DateTime createdAt;

  const PracticeQuestionRow({
    required this.id,
    required this.courseId,
    required this.sortOrder,
    required this.question,
    required this.optionsJson,
    required this.correctIndex,
    required this.explanation,
    this.sourceDocument,
    this.sourcePage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'course_id': courseId,
        'sort_order': sortOrder,
        'question': question,
        'options_json': optionsJson,
        'correct_index': correctIndex,
        'explanation': explanation,
        'source_document': sourceDocument,
        'source_page': sourcePage,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  static PracticeQuestionRow fromMap(Map<String, dynamic> m) =>
      PracticeQuestionRow(
        id: m['id'] as String,
        courseId: m['course_id'] as String,
        sortOrder: m['sort_order'] as int,
        question: m['question'] as String,
        optionsJson: m['options_json'] as String,
        correctIndex: m['correct_index'] as int,
        explanation: m['explanation'] as String,
        sourceDocument: m['source_document'] as String?,
        sourcePage: m['source_page'] as int?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
      );
}

/// Data-access object for the `practice_questions` table.
///
/// Generated question sets for a course are stored as an ordered list.
/// Calling [replaceByCourseId] atomically replaces the old set with the new
/// one inside a transaction.
class PracticeQuestionDao {
  final DatabaseHelper _dbHelper;

  PracticeQuestionDao([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // ─────────────────────────── READ ────────────────────────────

  /// Returns all practice questions for [courseId], ordered by [sort_order].
  Future<Result<List<PracticeQuestionRow>>> getByCourseId(
      String courseId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'practice_questions',
        where: 'course_id = ?',
        whereArgs: [courseId],
        orderBy: 'sort_order ASC',
      );
      return Success(maps.map(PracticeQuestionRow.fromMap).toList());
    } catch (e) {
      return Failure('Failed to load practice questions', e);
    }
  }

  // ─────────────────────────── WRITE ───────────────────────────

  /// Atomically replaces all practice questions for [courseId] with [rows].
  Future<Result<void>> replaceByCourseId(
    String courseId,
    List<PracticeQuestionRow> rows,
  ) async {
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        await txn.delete(
          'practice_questions',
          where: 'course_id = ?',
          whereArgs: [courseId],
        );
        for (final row in rows) {
          await txn.insert(
            'practice_questions',
            row.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      return const Success(null);
    } catch (e) {
      return Failure('Failed to save practice questions', e);
    }
  }

  /// Deletes all practice questions for [courseId].
  Future<Result<void>> deleteAllByCourseId(String courseId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'practice_questions',
        where: 'course_id = ?',
        whereArgs: [courseId],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete practice questions', e);
    }
  }
}
