import '../models/note_model.dart';
import 'database_helper.dart';

class NoteDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // 插入笔记
  Future<int> insertNote(Note note) async {
    final db = await _databaseHelper.database;
    return await db.insert('notes', note.toJson());
  }

  // 根据ID获取笔记
  Future<Note?> getNoteById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    }
    return null;
  }

  // 获取用户的所有笔记
  Future<List<Note>> getNotesByUserId(int userId, {bool includeArchived = false}) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: includeArchived ? 'user_id = ?' : 'user_id = ? AND is_archived = 0',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Note.fromJson(maps[i]);
    });
  }

  // 获取用户的归档笔记
  Future<List<Note>> getArchivedNotesByUserId(int userId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'user_id = ? AND is_archived = 1',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Note.fromJson(maps[i]);
    });
  }

  // 搜索笔记
  Future<List<Note>> searchNotes(int userId, String keyword) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'user_id = ? AND (title LIKE ? OR content LIKE ?) AND is_archived = 0',
      whereArgs: [userId, '%$keyword%', '%$keyword%'],
      orderBy: 'updated_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Note.fromJson(maps[i]);
    });
  }

  // 更新笔记
  Future<int> updateNote(Note note) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'notes',
      note.copyWith(updatedAt: DateTime.now()).toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // 归档/取消归档笔记
  Future<int> toggleArchiveNote(int noteId, bool isArchived) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'notes',
      {
        'is_archived': isArchived ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  // 删除笔记
  Future<int> deleteNote(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 删除用户的所有笔记
  Future<int> deleteAllNotesByUserId(int userId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'notes',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // 获取笔记总数
  Future<int> getNotesCount(int userId, {bool includeArchived = false}) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      includeArchived 
        ? 'SELECT COUNT(*) as count FROM notes WHERE user_id = ?'
        : 'SELECT COUNT(*) as count FROM notes WHERE user_id = ? AND is_archived = 0',
      [userId],
    );
    return result.first['count'] as int;
  }
}