import 'package:sqflite/sqflite.dart';

import 'package:study_notebook/core/models/models.dart';

import 'database_helper.dart';

/// Data-access object for the `text_elements` table.
class TextElementDao {
  final DatabaseHelper _dbHelper;

  TextElementDao([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Map<String, dynamic> _toMap(TextElement el) => {
        'id': el.id,
        'page_id': el.pageId,
        'content': el.content,
        'x': el.x,
        'y': el.y,
        'width': el.width,
        'font_size': el.fontSize,
        'font_family': el.fontFamily,
        'color': el.color,
        'is_bold': el.isBold ? 1 : 0,
        'is_italic': el.isItalic ? 1 : 0,
        'created_at': el.createdAt.millisecondsSinceEpoch,
        'is_deleted': el.isDeleted ? 1 : 0,
      };

  TextElement _fromMap(Map<String, dynamic> map) => TextElement(
        id: map['id'] as String,
        pageId: map['page_id'] as String,
        content: map['content'] as String,
        x: (map['x'] as num).toDouble(),
        y: (map['y'] as num).toDouble(),
        width: (map['width'] as num).toDouble(),
        fontSize: (map['font_size'] as num?)?.toDouble() ?? 16.0,
        fontFamily: map['font_family'] as String? ?? 'system',
        color: map['color'] as String? ?? '#000000',
        isBold: (map['is_bold'] as int? ?? 0) == 1,
        isItalic: (map['is_italic'] as int? ?? 0) == 1,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        isDeleted: (map['is_deleted'] as int) == 1,
      );

  Future<Result<List<TextElement>>> getByPageId(String pageId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'text_elements',
        where: 'page_id = ? AND is_deleted = 0',
        whereArgs: [pageId],
      );
      return Success(maps.map(_fromMap).toList());
    } catch (e) {
      return Failure('Failed to get text elements', e);
    }
  }

  Future<Result<void>> insert(TextElement el) async {
    try {
      final db = await _dbHelper.database;
      await db.insert('text_elements', _toMap(el),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to insert text element', e);
    }
  }

  Future<Result<void>> update(TextElement el) async {
    try {
      final db = await _dbHelper.database;
      await db.update('text_elements', _toMap(el),
          where: 'id = ?', whereArgs: [el.id]);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update text element', e);
    }
  }

  Future<Result<void>> deleteByPageId(String pageId) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'text_elements',
        {'is_deleted': 1},
        where: 'page_id = ?',
        whereArgs: [pageId],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete text elements', e);
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'text_elements',
        {'is_deleted': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete text element', e);
    }
  }

  Future<Result<void>> insertBatch(List<TextElement> elements) async {
    try {
      final db = await _dbHelper.database;
      final batch = db.batch();
      for (final el in elements) {
        batch.insert('text_elements', _toMap(el),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to batch insert text elements', e);
    }
  }
}
