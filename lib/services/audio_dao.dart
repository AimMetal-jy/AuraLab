import '../models/audio_record_model.dart';
import 'database_helper.dart';

class AudioDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // 插入音频记录
  Future<int> insertAudioRecord(AudioRecord audioRecord) async {
    final db = await _databaseHelper.database;
    return await db.insert('audio_records', audioRecord.toJson());
  }

  // 根据ID获取音频记录
  Future<AudioRecord?> getAudioRecordById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'audio_records',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return AudioRecord.fromJson(maps.first);
    }
    return null;
  }

  // 获取用户的所有音频记录
  Future<List<AudioRecord>> getAudioRecordsByUserId(int userId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'audio_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return AudioRecord.fromJson(maps[i]);
    });
  }

  // 搜索音频记录（根据文件名或转录文本）
  Future<List<AudioRecord>> searchAudioRecords(int userId, String keyword) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'audio_records',
      where: 'user_id = ? AND (file_name LIKE ? OR transcription LIKE ?)',
      whereArgs: [userId, '%$keyword%', '%$keyword%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return AudioRecord.fromJson(maps[i]);
    });
  }

  // 更新音频记录（主要用于更新转录文本）
  Future<int> updateAudioRecord(AudioRecord audioRecord) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'audio_records',
      audioRecord.toJson(),
      where: 'id = ?',
      whereArgs: [audioRecord.id],
    );
  }

  // 更新转录文本
  Future<int> updateTranscription(int audioRecordId, String transcription) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'audio_records',
      {'transcription': transcription},
      where: 'id = ?',
      whereArgs: [audioRecordId],
    );
  }

  // 删除音频记录
  Future<int> deleteAudioRecord(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'audio_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 删除用户的所有音频记录
  Future<int> deleteAllAudioRecordsByUserId(int userId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'audio_records',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // 获取音频记录总数
  Future<int> getAudioRecordsCount(int userId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM audio_records WHERE user_id = ?',
      [userId],
    );
    return result.first['count'] as int;
  }

  // 获取总音频时长
  Future<int> getTotalDuration(int userId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(duration) as total_duration FROM audio_records WHERE user_id = ? AND duration IS NOT NULL',
      [userId],
    );
    return (result.first['total_duration'] as int?) ?? 0;
  }

  // 根据日期范围获取音频记录
  Future<List<AudioRecord>> getAudioRecordsByDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'audio_records',
      where: 'user_id = ? AND created_at >= ? AND created_at <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return AudioRecord.fromJson(maps[i]);
    });
  }
}