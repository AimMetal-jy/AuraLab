import '../models/vocabulary_model.dart';
import 'database_helper.dart';

class VocabularyDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // 插入词汇
  Future<int> insertVocabulary(Vocabulary vocabulary) async {
    final db = await _databaseHelper.database;
    return await db.insert('vocabulary', vocabulary.toJson());
  }

  // 根据ID获取词汇
  Future<Vocabulary?> getVocabularyById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vocabulary',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Vocabulary.fromJson(maps.first);
    }
    return null;
  }

  // 获取用户的所有词汇
  Future<List<Vocabulary>> getVocabulariesByUserId(int userId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vocabulary',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Vocabulary.fromJson(maps[i]);
    });
  }

  // 搜索词汇
  Future<List<Vocabulary>> searchVocabularies(int userId, String keyword) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vocabulary',
      where: 'user_id = ? AND (word LIKE ? OR translation LIKE ? OR example_sentence LIKE ?)',
      whereArgs: [userId, '%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Vocabulary.fromJson(maps[i]);
    });
  }

  // 检查词汇是否已存在
  Future<bool> isWordExists(int userId, String word) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vocabulary',
      where: 'user_id = ? AND word = ?',
      whereArgs: [userId, word.toLowerCase()],
    );

    return maps.isNotEmpty;
  }

  // 根据单词获取词汇
  Future<Vocabulary?> getVocabularyByWord(int userId, String word) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vocabulary',
      where: 'user_id = ? AND word = ?',
      whereArgs: [userId, word.toLowerCase()],
    );

    if (maps.isNotEmpty) {
      return Vocabulary.fromJson(maps.first);
    }
    return null;
  }

  // 更新词汇
  Future<int> updateVocabulary(Vocabulary vocabulary) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'vocabulary',
      vocabulary.toJson(),
      where: 'id = ?',
      whereArgs: [vocabulary.id],
    );
  }

  // 删除词汇
  Future<int> deleteVocabulary(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'vocabulary',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 删除用户的所有词汇
  Future<int> deleteAllVocabulariesByUserId(int userId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'vocabulary',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // 获取词汇总数
  Future<int> getVocabulariesCount(int userId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM vocabulary WHERE user_id = ?',
      [userId],
    );
    return result.first['count'] as int;
  }

  // 获取最近添加的词汇
  Future<List<Vocabulary>> getRecentVocabularies(int userId, {int limit = 10}) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vocabulary',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return Vocabulary.fromJson(maps[i]);
    });
  }

  // 按字母顺序获取词汇
  Future<List<Vocabulary>> getVocabulariesAlphabetically(int userId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vocabulary',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'word ASC',
    );

    return List.generate(maps.length, (i) {
      return Vocabulary.fromJson(maps[i]);
    });
  }

  // 根据日期范围获取词汇
  Future<List<Vocabulary>> getVocabulariesByDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vocabulary',
      where: 'user_id = ? AND created_at >= ? AND created_at <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Vocabulary.fromJson(maps[i]);
    });
  }
}