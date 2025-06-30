import '../models/user_model.dart';
import '../models/note_model.dart';
import '../models/audio_record_model.dart';
import '../models/vocabulary_model.dart';
import 'database_helper.dart';
import 'note_dao.dart';
import 'audio_dao.dart';
import 'vocabulary_dao.dart';

/// 本地数据服务类
/// 统一管理所有本地SQLite数据操作
class LocalDataService {
  static final LocalDataService _instance = LocalDataService._internal();
  factory LocalDataService() => _instance;
  LocalDataService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NoteDao _noteDao = NoteDao();
  final AudioDao _audioDao = AudioDao();
  final VocabularyDao _vocabularyDao = VocabularyDao();

  // 用户相关操作
  Future<User?> getCurrentUser() async {
    // 这里可以实现获取当前登录用户的逻辑
    // 暂时返回null，需要结合应用的用户状态管理
    return null;
  }

  Future<bool> saveUser(User user) async {
    try {
      await _databaseHelper.insertUser(user);
      return true;
    } catch (e) {
      print('保存用户失败: $e');
      return false;
    }
  }

  Future<User?> getUserById(int id) async {
    return await _databaseHelper.getUserById(id);
  }

  Future<User?> getUserByUsername(String username) async {
    return await _databaseHelper.getUserByUsername(username);
  }

  // 笔记相关操作
  Future<List<Note>> getUserNotes(int userId, {bool includeArchived = false}) async {
    return await _noteDao.getNotesByUserId(userId, includeArchived: includeArchived);
  }

  Future<List<Note>> getArchivedNotes(int userId) async {
    return await _noteDao.getArchivedNotesByUserId(userId);
  }

  Future<List<Note>> searchNotes(int userId, String keyword) async {
    return await _noteDao.searchNotes(userId, keyword);
  }

  Future<bool> saveNote(Note note) async {
    try {
      if (note.id == null) {
        await _noteDao.insertNote(note);
      } else {
        await _noteDao.updateNote(note);
      }
      return true;
    } catch (e) {
      print('保存笔记失败: $e');
      return false;
    }
  }

  Future<bool> deleteNote(int noteId) async {
    try {
      await _noteDao.deleteNote(noteId);
      return true;
    } catch (e) {
      print('删除笔记失败: $e');
      return false;
    }
  }

  Future<bool> toggleArchiveNote(int noteId, bool isArchived) async {
    try {
      await _noteDao.toggleArchiveNote(noteId, isArchived);
      return true;
    } catch (e) {
      print('归档/取消归档笔记失败: $e');
      return false;
    }
  }

  Future<int> getNotesCount(int userId, {bool includeArchived = false}) async {
    return await _noteDao.getNotesCount(userId, includeArchived: includeArchived);
  }

  // 音频记录相关操作
  Future<List<AudioRecord>> getUserAudioRecords(int userId) async {
    return await _audioDao.getAudioRecordsByUserId(userId);
  }

  Future<List<AudioRecord>> searchAudioRecords(int userId, String keyword) async {
    return await _audioDao.searchAudioRecords(userId, keyword);
  }

  Future<bool> saveAudioRecord(AudioRecord audioRecord) async {
    try {
      if (audioRecord.id == null) {
        await _audioDao.insertAudioRecord(audioRecord);
      } else {
        await _audioDao.updateAudioRecord(audioRecord);
      }
      return true;
    } catch (e) {
      print('保存音频记录失败: $e');
      return false;
    }
  }

  Future<bool> updateTranscription(int audioRecordId, String transcription) async {
    try {
      await _audioDao.updateTranscription(audioRecordId, transcription);
      return true;
    } catch (e) {
      print('更新转录文本失败: $e');
      return false;
    }
  }

  Future<bool> deleteAudioRecord(int audioRecordId) async {
    try {
      await _audioDao.deleteAudioRecord(audioRecordId);
      return true;
    } catch (e) {
      print('删除音频记录失败: $e');
      return false;
    }
  }

  Future<int> getAudioRecordsCount(int userId) async {
    return await _audioDao.getAudioRecordsCount(userId);
  }

  Future<int> getTotalAudioDuration(int userId) async {
    return await _audioDao.getTotalDuration(userId);
  }

  // 词汇表相关操作
  Future<List<Vocabulary>> getUserVocabularies(int userId) async {
    return await _vocabularyDao.getVocabulariesByUserId(userId);
  }

  Future<List<Vocabulary>> searchVocabularies(int userId, String keyword) async {
    return await _vocabularyDao.searchVocabularies(userId, keyword);
  }

  Future<List<Vocabulary>> getRecentVocabularies(int userId, {int limit = 10}) async {
    return await _vocabularyDao.getRecentVocabularies(userId, limit: limit);
  }

  Future<List<Vocabulary>> getVocabulariesAlphabetically(int userId) async {
    return await _vocabularyDao.getVocabulariesAlphabetically(userId);
  }

  Future<bool> saveVocabulary(Vocabulary vocabulary) async {
    try {
      if (vocabulary.id == null) {
        await _vocabularyDao.insertVocabulary(vocabulary);
      } else {
        await _vocabularyDao.updateVocabulary(vocabulary);
      }
      return true;
    } catch (e) {
      print('保存词汇失败: $e');
      return false;
    }
  }

  Future<bool> deleteVocabulary(int vocabularyId) async {
    try {
      await _vocabularyDao.deleteVocabulary(vocabularyId);
      return true;
    } catch (e) {
      print('删除词汇失败: $e');
      return false;
    }
  }

  Future<bool> isWordExists(int userId, String word) async {
    return await _vocabularyDao.isWordExists(userId, word);
  }

  Future<Vocabulary?> getVocabularyByWord(int userId, String word) async {
    return await _vocabularyDao.getVocabularyByWord(userId, word);
  }

  Future<int> getVocabulariesCount(int userId) async {
    return await _vocabularyDao.getVocabulariesCount(userId);
  }

  // 数据统计
  Future<Map<String, int>> getUserDataStatistics(int userId) async {
    try {
      final notesCount = await getNotesCount(userId);
      final audioRecordsCount = await getAudioRecordsCount(userId);
      final vocabulariesCount = await getVocabulariesCount(userId);
      final totalAudioDuration = await getTotalAudioDuration(userId);

      return {
        'notesCount': notesCount,
        'audioRecordsCount': audioRecordsCount,
        'vocabulariesCount': vocabulariesCount,
        'totalAudioDuration': totalAudioDuration,
      };
    } catch (e) {
      print('获取用户数据统计失败: $e');
      return {
        'notesCount': 0,
        'audioRecordsCount': 0,
        'vocabulariesCount': 0,
        'totalAudioDuration': 0,
      };
    }
  }

  // 数据清理
  Future<bool> clearUserData(int userId) async {
    try {
      await _noteDao.deleteAllNotesByUserId(userId);
      await _audioDao.deleteAllAudioRecordsByUserId(userId);
      await _vocabularyDao.deleteAllVocabulariesByUserId(userId);
      return true;
    } catch (e) {
      print('清理用户数据失败: $e');
      return false;
    }
  }

  Future<bool> clearAllData() async {
    try {
      await _databaseHelper.clearAllData();
      return true;
    } catch (e) {
      print('清理所有数据失败: $e');
      return false;
    }
  }

  // 数据库初始化
  Future<bool> initializeDatabase() async {
    try {
      await _databaseHelper.database;
      return true;
    } catch (e) {
      print('数据库初始化失败: $e');
      return false;
    }
  }

  // 关闭数据库连接
  Future<void> closeDatabase() async {
    await _databaseHelper.close();
  }
}