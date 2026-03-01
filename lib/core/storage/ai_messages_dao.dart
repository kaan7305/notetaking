import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:study_notebook/core/models/models.dart';

import 'database_helper.dart';

/// Data-access object for the `ai_messages` table.
///
/// Persists AI chat messages per course so history survives app restarts.
/// Image payloads (base64) are intentionally NOT stored to keep the database
/// lean — they are only needed at the moment of sending.
class AiMessagesDao {
  final DatabaseHelper _dbHelper;

  AiMessagesDao([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // ──────────────────── helpers ────────────────────

  Map<String, dynamic> _toMap(AiMessage message) => {
        'id': message.id,
        'course_id': message.courseId,
        'role': message.role,
        'content': message.content,
        // Intentionally skip image_base64 — large payloads, only needed
        // at send time.  Already NULL in the schema default.
        'image_base64': null,
        'mode': message.mode,
        'references_json': message.references.isNotEmpty
            ? jsonEncode(
                message.references.map((r) => r.toJson()).toList(),
              )
            : null,
        'created_at': message.createdAt.millisecondsSinceEpoch,
      };

  AiMessage _fromMap(Map<String, dynamic> map) {
    final refsString = map['references_json'] as String?;
    final references = refsString != null
        ? (jsonDecode(refsString) as List)
            .map((r) => SourceReference.fromJson(r as Map<String, dynamic>))
            .toList()
        : <SourceReference>[];

    return AiMessage(
      id: map['id'] as String,
      courseId: map['course_id'] as String,
      role: map['role'] as String,
      content: map['content'] as String,
      // image_base64 not restored from DB (see _toMap).
      mode: map['mode'] as String,
      references: references,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // ──────────────────── CRUD ────────────────────

  /// Persists a single [message].
  Future<Result<AiMessage>> insert(AiMessage message) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'ai_messages',
        _toMap(message),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Success(message);
    } catch (e) {
      return Failure('Failed to insert AI message', e);
    }
  }

  /// Returns all messages for [courseId], ordered oldest-first.
  Future<Result<List<AiMessage>>> getByCourseId(String courseId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'ai_messages',
        where: 'course_id = ?',
        whereArgs: [courseId],
        orderBy: 'created_at ASC',
      );
      return Success(maps.map(_fromMap).toList());
    } catch (e) {
      return Failure('Failed to load AI messages', e);
    }
  }

  /// Deletes all messages for [courseId] (e.g. when the user clears chat).
  Future<Result<void>> deleteAllByCourseId(String courseId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'ai_messages',
        where: 'course_id = ?',
        whereArgs: [courseId],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete AI messages', e);
    }
  }

  /// Keeps only the [keep] most-recent messages for [courseId], deleting
  /// older rows to prevent unbounded database growth.
  Future<Result<void>> pruneOldMessages(
    String courseId, {
    int keep = 100,
  }) async {
    try {
      final db = await _dbHelper.database;
      // Delete all rows except the [keep] newest ones.
      await db.rawDelete('''
        DELETE FROM ai_messages
        WHERE course_id = ?
          AND id NOT IN (
            SELECT id FROM ai_messages
            WHERE course_id = ?
            ORDER BY created_at DESC
            LIMIT ?
          )
      ''', [courseId, courseId, keep]);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to prune AI messages', e);
    }
  }
}
