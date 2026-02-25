import 'package:sqflite/sqflite.dart';

import 'package:study_notebook/core/models/models.dart';

import 'database_helper.dart';

/// Data-access object for the `documents` table.
class DocumentDao {
  final DatabaseHelper _dbHelper;

  DocumentDao([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // ──────────────────── helpers ────────────────────

  Map<String, dynamic> _toMap(Document document) => {
        'id': document.id,
        'course_id': document.courseId,
        'user_id': document.userId,
        'file_name': document.fileName,
        'storage_path': document.storagePath,
        'local_path': document.localPath,
        'page_count': document.pageCount,
        'status': document.status,
        'created_at': document.createdAt.millisecondsSinceEpoch,
        'is_synced': document.isSynced ? 1 : 0,
      };

  Document _fromMap(Map<String, dynamic> map) => Document(
        id: map['id'] as String,
        courseId: map['course_id'] as String,
        userId: map['user_id'] as String,
        fileName: map['file_name'] as String,
        storagePath: map['storage_path'] as String,
        localPath: map['local_path'] as String?,
        pageCount: map['page_count'] as int? ?? 0,
        status: map['status'] as String? ?? 'uploading',
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        isSynced: (map['is_synced'] as int) == 1,
      );

  // ──────────────────── CRUD ────────────────────

  Future<Result<Document>> insert(Document document) async {
    try {
      final db = await _dbHelper.database;
      await db.insert('documents', _toMap(document),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return Success(document);
    } catch (e) {
      return Failure('Failed to insert document', e);
    }
  }

  Future<Result<Document>> getById(String id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'documents',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) {
        return const Failure('Document not found');
      }
      return Success(_fromMap(maps.first));
    } catch (e) {
      return Failure('Failed to get document', e);
    }
  }

  Future<Result<void>> update(Document document) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'documents',
        _toMap(document),
        where: 'id = ?',
        whereArgs: [document.id],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update document', e);
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'documents',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete document', e);
    }
  }

  // ──────────────────── queries ────────────────────

  Future<Result<List<Document>>> getByCourseId(String courseId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'documents',
        where: 'course_id = ?',
        whereArgs: [courseId],
        orderBy: 'created_at DESC',
      );
      return Success(maps.map(_fromMap).toList());
    } catch (e) {
      return Failure('Failed to get documents for course', e);
    }
  }

  Future<Result<Document>> getByFileName(
      String courseId, String fileName) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'documents',
        where: 'course_id = ? AND file_name = ?',
        whereArgs: [courseId, fileName],
        limit: 1,
      );
      if (maps.isEmpty) {
        return const Failure('Document not found');
      }
      return Success(_fromMap(maps.first));
    } catch (e) {
      return Failure('Failed to get document by file name', e);
    }
  }

  // ──────────────────── sync ────────────────────

  Future<Result<List<Document>>> getUnsynced() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'documents',
        where: 'is_synced = 0',
      );
      return Success(maps.map(_fromMap).toList());
    } catch (e) {
      return Failure('Failed to get unsynced documents', e);
    }
  }

  Future<Result<void>> markSynced(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'documents',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to mark document as synced', e);
    }
  }
}
