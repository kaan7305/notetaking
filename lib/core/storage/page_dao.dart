import 'package:sqflite/sqflite.dart';

import 'package:study_notebook/core/models/models.dart';

import 'database_helper.dart';

/// Data-access object for the `pages` table.
class PageDao {
  final DatabaseHelper _dbHelper;

  PageDao([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // ──────────────────── helpers ────────────────────

  Map<String, dynamic> _toMap(PageModel page) => {
        'id': page.id,
        'notebook_id': page.notebookId,
        'page_number': page.pageNumber,
        'template_type': page.templateType,
        'background_color': page.backgroundColor,
        'line_spacing': page.lineSpacing,
        'thumbnail_path': page.thumbnailPath,
        'created_at': page.createdAt.millisecondsSinceEpoch,
        'updated_at': page.updatedAt.millisecondsSinceEpoch,
        'is_synced': page.isSynced ? 1 : 0,
      };

  PageModel _fromMap(Map<String, dynamic> map) => PageModel(
        id: map['id'] as String,
        notebookId: map['notebook_id'] as String,
        pageNumber: map['page_number'] as int,
        templateType: map['template_type'] as String? ?? 'blank',
        backgroundColor: map['background_color'] as String? ?? '#FFFFFF',
        lineSpacing: (map['line_spacing'] as num?)?.toDouble() ?? 32.0,
        thumbnailPath: map['thumbnail_path'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
        isSynced: (map['is_synced'] as int) == 1,
      );

  // ──────────────────── CRUD ────────────────────

  Future<Result<PageModel>> insert(PageModel page) async {
    try {
      final db = await _dbHelper.database;
      await db.insert('pages', _toMap(page),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return Success(page);
    } catch (e) {
      return Failure('Failed to insert page', e);
    }
  }

  Future<Result<PageModel>> getById(String id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'pages',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) {
        return const Failure('Page not found');
      }
      return Success(_fromMap(maps.first));
    } catch (e) {
      return Failure('Failed to get page', e);
    }
  }

  Future<Result<void>> update(PageModel page) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'pages',
        _toMap(page),
        where: 'id = ?',
        whereArgs: [page.id],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update page', e);
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'pages',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete page', e);
    }
  }

  // ──────────────────── queries ────────────────────

  Future<Result<List<PageModel>>> getByNotebookId(String notebookId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'pages',
        where: 'notebook_id = ?',
        whereArgs: [notebookId],
        orderBy: 'page_number ASC',
      );
      return Success(maps.map(_fromMap).toList());
    } catch (e) {
      return Failure('Failed to get pages for notebook', e);
    }
  }

  Future<Result<int>> getMaxPageNumber(String notebookId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT MAX(page_number) as max_page FROM pages WHERE notebook_id = ?',
        [notebookId],
      );
      final maxPage = result.first['max_page'] as int?;
      return Success(maxPage ?? 0);
    } catch (e) {
      return Failure('Failed to get max page number', e);
    }
  }

  // ──────────────────── sync ────────────────────

  Future<Result<List<PageModel>>> getUnsynced() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'pages',
        where: 'is_synced = 0',
      );
      return Success(maps.map(_fromMap).toList());
    } catch (e) {
      return Failure('Failed to get unsynced pages', e);
    }
  }

  Future<Result<void>> markSynced(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'pages',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to mark page as synced', e);
    }
  }
}
