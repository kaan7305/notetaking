import 'package:sqflite/sqflite.dart';

import 'package:study_notebook/core/models/models.dart';

import 'database_helper.dart';

/// Data-access object for the `notebooks` table.
class NotebookDao {
  final DatabaseHelper _dbHelper;

  NotebookDao([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // ──────────────────── helpers ────────────────────

  Map<String, dynamic> _toMap(Notebook notebook) => {
        'id': notebook.id,
        'course_id': notebook.courseId,
        'user_id': notebook.userId,
        'title': notebook.title,
        'cover_image_path': notebook.coverImagePath,
        'page_size': notebook.pageSize,
        'created_at': notebook.createdAt.millisecondsSinceEpoch,
        'updated_at': notebook.updatedAt.millisecondsSinceEpoch,
        'is_favorite': notebook.isFavorite ? 1 : 0,
        'is_synced': notebook.isSynced ? 1 : 0,
      };

  Notebook _fromMap(Map<String, dynamic> map) => Notebook(
        id: map['id'] as String,
        courseId: map['course_id'] as String,
        userId: map['user_id'] as String,
        title: map['title'] as String,
        coverImagePath: map['cover_image_path'] as String?,
        pageSize: map['page_size'] as String? ?? 'letter',
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
        isFavorite: (map['is_favorite'] as int) == 1,
        isSynced: (map['is_synced'] as int) == 1,
      );

  // ──────────────────── CRUD ────────────────────

  Future<Result<Notebook>> insert(Notebook notebook) async {
    try {
      final db = await _dbHelper.database;
      await db.insert('notebooks', _toMap(notebook),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return Success(notebook);
    } catch (e) {
      return Failure('Failed to insert notebook', e);
    }
  }

  Future<Result<Notebook>> getById(String id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'notebooks',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) {
        return const Failure('Notebook not found');
      }
      return Success(_fromMap(maps.first));
    } catch (e) {
      return Failure('Failed to get notebook', e);
    }
  }

  Future<Result<void>> update(Notebook notebook) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'notebooks',
        _toMap(notebook),
        where: 'id = ?',
        whereArgs: [notebook.id],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update notebook', e);
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'notebooks',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete notebook', e);
    }
  }

  // ──────────────────── queries ────────────────────

  Future<Result<List<Notebook>>> getByUserId(String userId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'notebooks',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'updated_at DESC',
      );
      return Success(maps.map(_fromMap).toList());
    } catch (e) {
      return Failure('Failed to get notebooks for user', e);
    }
  }

  Future<Result<List<Notebook>>> getByCourseId(String courseId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'notebooks',
        where: 'course_id = ?',
        whereArgs: [courseId],
        orderBy: 'updated_at DESC',
      );
      return Success(maps.map(_fromMap).toList());
    } catch (e) {
      return Failure('Failed to get notebooks for course', e);
    }
  }

  Future<Result<List<Notebook>>> getFavorites(String userId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'notebooks',
        where: 'user_id = ? AND is_favorite = 1',
        whereArgs: [userId],
        orderBy: 'updated_at DESC',
      );
      return Success(maps.map(_fromMap).toList());
    } catch (e) {
      return Failure('Failed to get favorite notebooks', e);
    }
  }

  Future<Result<List<Notebook>>> getRecent(String userId,
      {int limit = 20}) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'notebooks',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'updated_at DESC',
        limit: limit,
      );
      return Success(maps.map(_fromMap).toList());
    } catch (e) {
      return Failure('Failed to get recent notebooks', e);
    }
  }

  // ──────────────────── sync ────────────────────

  Future<Result<List<Notebook>>> getUnsynced() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'notebooks',
        where: 'is_synced = 0',
      );
      return Success(maps.map(_fromMap).toList());
    } catch (e) {
      return Failure('Failed to get unsynced notebooks', e);
    }
  }

  Future<Result<void>> markSynced(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'notebooks',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to mark notebook as synced', e);
    }
  }
}
