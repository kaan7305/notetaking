import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:study_notebook/core/models/models.dart';

import 'database_helper.dart';

/// Data-access object for the `strokes` table.
///
/// Stroke points are stored as a JSON-encoded string in the `points` column.
class StrokeDao {
  final DatabaseHelper _dbHelper;

  StrokeDao([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // ──────────────────── helpers ────────────────────

  Map<String, dynamic> _toMap(Stroke stroke) => {
        'id': stroke.id,
        'page_id': stroke.pageId,
        'tool_type': stroke.toolType,
        'color': stroke.color,
        'stroke_width': stroke.strokeWidth,
        'points':
            jsonEncode(stroke.points.map((p) => p.toJson()).toList()),
        'created_at': stroke.createdAt.millisecondsSinceEpoch,
        'is_deleted': stroke.isDeleted ? 1 : 0,
      };

  Stroke _fromMap(Map<String, dynamic> map) {
    final pointsJson = map['points'] as String;
    final points = (jsonDecode(pointsJson) as List)
        .map((p) => StrokePoint.fromJson(p as Map<String, dynamic>))
        .toList();

    return Stroke(
      id: map['id'] as String,
      pageId: map['page_id'] as String,
      toolType: map['tool_type'] as String,
      color: map['color'] as String,
      strokeWidth: (map['stroke_width'] as num).toDouble(),
      points: points,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      isDeleted: (map['is_deleted'] as int) == 1,
    );
  }

  // ──────────────────── CRUD ────────────────────

  Future<Result<Stroke>> insert(Stroke stroke) async {
    try {
      final db = await _dbHelper.database;
      await db.insert('strokes', _toMap(stroke),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return Success(stroke);
    } catch (e) {
      return Failure('Failed to insert stroke', e);
    }
  }

  Future<Result<Stroke>> getById(String id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'strokes',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) {
        return const Failure('Stroke not found');
      }
      return Success(_fromMap(maps.first));
    } catch (e) {
      return Failure('Failed to get stroke', e);
    }
  }

  /// Soft-deletes a stroke by setting `is_deleted = 1`.
  Future<Result<void>> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'strokes',
        {'is_deleted': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete stroke', e);
    }
  }

  // ──────────────────── batch ────────────────────

  /// Inserts multiple strokes in a single database transaction for performance.
  Future<Result<void>> insertBatch(List<Stroke> strokes) async {
    try {
      final db = await _dbHelper.database;
      final batch = db.batch();
      for (final stroke in strokes) {
        batch.insert('strokes', _toMap(stroke),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to batch insert strokes', e);
    }
  }

  // ──────────────────── queries ────────────────────

  /// Returns all non-deleted strokes for the given page.
  Future<Result<List<Stroke>>> getByPageId(String pageId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'strokes',
        where: 'page_id = ? AND is_deleted = 0',
        whereArgs: [pageId],
      );
      return Success(maps.map(_fromMap).toList());
    } catch (e) {
      return Failure('Failed to get strokes for page', e);
    }
  }

  /// Soft-deletes all strokes on the given page.
  Future<Result<void>> deleteByPageId(String pageId) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'strokes',
        {'is_deleted': 1},
        where: 'page_id = ?',
        whereArgs: [pageId],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete strokes for page', e);
    }
  }

  // ──────────────────── sync ────────────────────

  Future<Result<List<Stroke>>> getUnsynced() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'strokes',
        where: 'is_deleted = 0',
      );
      return Success(maps.map(_fromMap).toList());
    } catch (e) {
      return Failure('Failed to get unsynced strokes', e);
    }
  }

  /// The strokes table does not have an `is_synced` column.
  /// This method is provided for interface consistency and is a no-op.
  Future<Result<void>> markSynced(String id) async {
    return const Success(null);
  }
}
