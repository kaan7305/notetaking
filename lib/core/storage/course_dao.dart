import 'package:sqflite/sqflite.dart';

import 'package:study_notebook/core/models/models.dart';

import 'database_helper.dart';

/// Data-access object for the `courses` table.
class CourseDao {
  final DatabaseHelper _dbHelper;

  CourseDao([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // ──────────────────── helpers ────────────────────

  Map<String, dynamic> _toMap(Course course) => {
        'id': course.id,
        'user_id': course.userId,
        'name': course.name,
        'description': course.description,
        'color': course.color,
        'created_at': course.createdAt.millisecondsSinceEpoch,
        'updated_at': course.updatedAt.millisecondsSinceEpoch,
        'is_synced': course.isSynced ? 1 : 0,
      };

  Course _fromMap(Map<String, dynamic> map) => Course(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        color: map['color'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
        isSynced: (map['is_synced'] as int) == 1,
      );

  // ──────────────────── CRUD ────────────────────

  Future<Result<Course>> insert(Course course) async {
    try {
      final db = await _dbHelper.database;
      await db.insert('courses', _toMap(course),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return Success(course);
    } catch (e) {
      return Failure('Failed to insert course', e);
    }
  }

  Future<Result<List<Course>>> getAll(String userId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'courses',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'updated_at DESC',
      );
      return Success(maps.map(_fromMap).toList());
    } catch (e) {
      return Failure('Failed to get courses', e);
    }
  }

  Future<Result<Course>> getById(String id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'courses',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) {
        return const Failure('Course not found');
      }
      return Success(_fromMap(maps.first));
    } catch (e) {
      return Failure('Failed to get course', e);
    }
  }

  Future<Result<void>> update(Course course) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'courses',
        _toMap(course),
        where: 'id = ?',
        whereArgs: [course.id],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update course', e);
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'courses',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete course', e);
    }
  }

  // ──────────────────── sync ────────────────────

  Future<Result<List<Course>>> getUnsynced() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'courses',
        where: 'is_synced = 0',
      );
      return Success(maps.map(_fromMap).toList());
    } catch (e) {
      return Failure('Failed to get unsynced courses', e);
    }
  }

  Future<Result<void>> markSynced(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'courses',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to mark course as synced', e);
    }
  }
}
