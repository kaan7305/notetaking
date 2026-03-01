import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:study_notebook/core/models/models.dart';

import 'database_helper.dart';

/// A single lecture-notes row as stored in SQLite.
class LectureNoteRow {
  final String id;
  final String courseId;
  final String title;
  final String summary;
  final List<String> keyPoints;
  final String fullNotes;
  final DateTime createdAt;

  const LectureNoteRow({
    required this.id,
    required this.courseId,
    required this.title,
    required this.summary,
    required this.keyPoints,
    required this.fullNotes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'course_id': courseId,
        'title': title,
        'summary': summary,
        'key_points_json': jsonEncode(keyPoints),
        'full_notes': fullNotes,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  static LectureNoteRow fromMap(Map<String, dynamic> m) {
    List<String> keyPoints;
    try {
      keyPoints = (jsonDecode(m['key_points_json'] as String) as List)
          .map((e) => e.toString())
          .toList();
    } catch (_) {
      keyPoints = [];
    }
    return LectureNoteRow(
      id: m['id'] as String,
      courseId: m['course_id'] as String,
      title: m['title'] as String,
      summary: m['summary'] as String,
      keyPoints: keyPoints,
      fullNotes: m['full_notes'] as String,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
    );
  }
}

/// Data-access object for the `lecture_notes` table.
///
/// Notes are appended on each generation and can be individually deleted.
/// [getMostRecentByCourseId] returns the latest note so the screen can
/// restore the last session's notes on re-open.
class LectureNoteDao {
  final DatabaseHelper _dbHelper;

  LectureNoteDao([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // ─────────────────────────── READ ────────────────────────────

  /// Returns all notes for [courseId], newest first.
  Future<Result<List<LectureNoteRow>>> getAllByCourseId(
      String courseId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'lecture_notes',
        where: 'course_id = ?',
        whereArgs: [courseId],
        orderBy: 'created_at DESC',
      );
      return Success(maps.map(LectureNoteRow.fromMap).toList());
    } catch (e) {
      return Failure('Failed to load lecture notes', e);
    }
  }

  /// Returns the most recently generated note for [courseId], or null.
  Future<Result<LectureNoteRow?>> getMostRecentByCourseId(
      String courseId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'lecture_notes',
        where: 'course_id = ?',
        whereArgs: [courseId],
        orderBy: 'created_at DESC',
        limit: 1,
      );
      final row = maps.isEmpty ? null : LectureNoteRow.fromMap(maps.first);
      return Success(row);
    } catch (e) {
      return Failure('Failed to load lecture notes', e);
    }
  }

  // ─────────────────────────── WRITE ───────────────────────────

  /// Inserts a new lecture note row.
  Future<Result<void>> insert(LectureNoteRow row) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'lecture_notes',
        row.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to save lecture note', e);
    }
  }

  /// Deletes the note with the given [id].
  Future<Result<void>> deleteById(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('lecture_notes', where: 'id = ?', whereArgs: [id]);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete lecture note', e);
    }
  }

  /// Deletes all notes for [courseId].
  Future<Result<void>> deleteAllByCourseId(String courseId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'lecture_notes',
        where: 'course_id = ?',
        whereArgs: [courseId],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete lecture notes', e);
    }
  }
}
