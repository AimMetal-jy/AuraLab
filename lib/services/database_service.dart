import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../screens/translate/translate_display_page.dart';
import '../screens/translate/translate.dart';
////这是翻译界面的数据库
/// 数据库服务类
/// 负责管理翻译相关数据的本地存储
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库（增强持久化配置）
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'auralab.db');
    final db = await openDatabase(
      path,
      version: 2,  // 增加版本号以触发数据库升级
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        try {
          // 配置SQLite以确保数据持久化
          await db.rawQuery('PRAGMA synchronous = FULL');
          await db.rawQuery('PRAGMA journal_mode = WAL');
          await db.rawQuery('PRAGMA foreign_keys = ON');
          print('DB: Database opened with enhanced persistence settings');
        } catch (e) {
          print('DB: Warning - Could not set PRAGMA settings: $e');
          // 继续执行，不让PRAGMA错误阻止数据库使用
        }
      },
    );
    return db;
  }

  /// 数据库升级处理
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('DB: Upgrading database from version $oldVersion to $newVersion');
    
    if (oldVersion < 2) {
      // 从版本1升级到版本2：修复card_instances表的主键问题
      print('DB: Upgrading to version 2 - fixing card_instances primary key');
      
      // 备份现有数据
      final existingCards = await db.query('card_instances');
      
      // 删除旧表
      await db.execute('DROP TABLE IF EXISTS card_instances');
      
      // 创建新表结构
      await db.execute('''
        CREATE TABLE card_instances (
          id TEXT NOT NULL,
          file_id TEXT NOT NULL,
          summary TEXT NOT NULL,
          original TEXT NOT NULL,
          translation TEXT NOT NULL,
          user_translation TEXT NOT NULL,
          show_summary INTEGER NOT NULL DEFAULT 1,
          show_original INTEGER NOT NULL DEFAULT 1,
          show_translation INTEGER NOT NULL DEFAULT 1,
          show_user_translation INTEGER NOT NULL DEFAULT 0,
          code_mode INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          PRIMARY KEY (id, file_id),
          FOREIGN KEY (file_id) REFERENCES translate_files (id) ON DELETE CASCADE
        )
      ''');
      
      // 恢复数据
      for (final card in existingCards) {
        await db.insert('card_instances', card, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      
      print('DB: Successfully upgraded card_instances table');
    }
  }
  
  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 创建翻译文件表
    await db.execute('''
      CREATE TABLE translate_files (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // 创建卡片实例表（使用复合主键确保多文件数据隔离）
    await db.execute('''
      CREATE TABLE card_instances (
        id TEXT NOT NULL,
        file_id TEXT NOT NULL,
        summary TEXT NOT NULL,
        original TEXT NOT NULL,
        translation TEXT NOT NULL,
        user_translation TEXT NOT NULL,
        show_summary INTEGER NOT NULL DEFAULT 1,
        show_original INTEGER NOT NULL DEFAULT 1,
        show_translation INTEGER NOT NULL DEFAULT 1,
        show_user_translation INTEGER NOT NULL DEFAULT 0,
        code_mode INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (id, file_id),
        FOREIGN KEY (file_id) REFERENCES translate_files (id) ON DELETE CASCADE
      )
    ''');
  }

  /// 保存翻译文件
  Future<void> saveTranslateFile(TranslateFile file) async {
    final db = await database;
    await db.insert(
      'translate_files',
      {
        'id': file.id,
        'title': file.title,
        'content': file.content,
        'created_at': file.createdAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取所有翻译文件
  Future<List<TranslateFile>> getTranslateFiles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'translate_files',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return TranslateFile(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(maps[i]['created_at']),
      );
    });
  }

  /// 删除翻译文件
  Future<void> deleteTranslateFile(String id) async {
    final db = await database;
    await db.delete(
      'translate_files',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 更新翻译文件
  Future<void> updateTranslateFile(TranslateFile file) async {
    final db = await database;
    await db.update(
      'translate_files',
      {
        'title': file.title,
        'content': file.content,
      },
      where: 'id = ?',
      whereArgs: [file.id],
    );
  }

  /// 保存卡片实例
  Future<void> saveCardInstance(String fileId, CardInstance card) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    print('DB: Saving card ${card.id} for fileId: $fileId');
    
    await db.insert(
      'card_instances',
      {
        'id': card.id,
        'file_id': fileId,
        'summary': card.summary,
        'original': card.original,
        'translation': card.translation,
        'user_translation': card.userTranslation,
        'show_summary': card.showSummary ? 1 : 0,
        'show_original': card.showOriginal ? 1 : 0,
        'show_translation': card.showTranslation ? 1 : 0,
        'show_user_translation': card.showUserTranslation ? 1 : 0,
        'code_mode': card.codeMode ? 1 : 0,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 更新卡片实例（带事务处理和强制同步）
  Future<void> updateCardInstance(String fileId, CardInstance card) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    print('DB: Updating card ${card.id} for fileId: $fileId');
    
    try {
      // 使用事务确保数据一致性
      await db.transaction((txn) async {
        // 使用INSERT with REPLACE确保无论记录是否存在都能正确保存
        await txn.insert(
          'card_instances',
          {
            'id': card.id,
            'file_id': fileId,
            'summary': card.summary,
            'original': card.original,
            'translation': card.translation,
            'user_translation': card.userTranslation,
            'show_summary': card.showSummary ? 1 : 0,
            'show_original': card.showOriginal ? 1 : 0,
            'show_translation': card.showTranslation ? 1 : 0,
            'show_user_translation': card.showUserTranslation ? 1 : 0,
            'code_mode': card.codeMode ? 1 : 0,
            'created_at': now,
            'updated_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        // 强制同步到磁盘（在事务中不需要重复设置PRAGMA）
        // PRAGMA设置已在数据库打开时配置
      });
      
      // 验证数据是否真正保存
      final savedCard = await getCardInstance(fileId, card.id);
      if (savedCard == null) {
        throw Exception('数据保存验证失败：卡片未找到');
      }
      
      print('DB: Card ${card.id} successfully saved and verified');
    } catch (e) {
      print('DB: Error updating card ${card.id}: $e');
      rethrow;
    }
  }

  /// 获取单个卡片实例（用于验证保存）
  Future<CardInstance?> getCardInstance(String fileId, String cardId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'card_instances',
      where: 'file_id = ? AND id = ?',
      whereArgs: [fileId, cardId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    
    final map = maps.first;
    return CardInstance(
      id: map['id'],
      summary: map['summary'],
      original: map['original'],
      translation: map['translation'],
      userTranslation: map['user_translation'],
      showSummary: map['show_summary'] == 1,
      showOriginal: map['show_original'] == 1,
      showTranslation: map['show_translation'] == 1,
      showUserTranslation: map['show_user_translation'] == 1,
      codeMode: map['code_mode'] == 1,
    );
  }

  /// 获取所有卡片实例（用于检查数据库状态）
  Future<List<CardInstance>> getAllCardInstances() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'card_instances',
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) {
      return CardInstance(
        id: maps[i]['id'],
        summary: maps[i]['summary'],
        original: maps[i]['original'],
        translation: maps[i]['translation'],
        userTranslation: maps[i]['user_translation'],
        showSummary: maps[i]['show_summary'] == 1,
        showOriginal: maps[i]['show_original'] == 1,
        showTranslation: maps[i]['show_translation'] == 1,
        showUserTranslation: maps[i]['show_user_translation'] == 1,
        codeMode: maps[i]['code_mode'] == 1,
      );
    });
  }

  /// 获取文件的所有卡片实例
  Future<List<CardInstance>> getCardInstances(String fileId) async {
    final db = await database;
    print('DB: Querying cards for fileId: $fileId');
    
    // 先查看数据库中所有的数据
    final allMaps = await db.query('card_instances');
    print('DB: Total cards in database: ${allMaps.length}');
    for (final map in allMaps) {
      print('DB: Card ${map['id']} belongs to fileId: ${map['file_id']}');
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'card_instances',
      where: 'file_id = ?',
      whereArgs: [fileId],
      orderBy: 'created_at ASC',
    );
    print('DB: Found ${maps.length} cards for fileId: $fileId');

    return List.generate(maps.length, (i) {
      return CardInstance(
        id: maps[i]['id'],
        summary: maps[i]['summary'],
        original: maps[i]['original'],
        translation: maps[i]['translation'],
        userTranslation: maps[i]['user_translation'],
        showSummary: maps[i]['show_summary'] == 1,
        showOriginal: maps[i]['show_original'] == 1,
        showTranslation: maps[i]['show_translation'] == 1,
        showUserTranslation: maps[i]['show_user_translation'] == 1,
        codeMode: maps[i]['code_mode'] == 1,
      );
    });
  }

  /// 删除卡片实例（需要指定文件ID和卡片ID）
  Future<void> deleteCardInstance(String fileId, String cardId) async {
    final db = await database;
    await db.delete(
      'card_instances',
      where: 'file_id = ? AND id = ?',
      whereArgs: [fileId, cardId],
    );
  }

  /// 删除文件的所有卡片实例
  Future<void> deleteCardInstancesByFileId(String fileId) async {
    final db = await database;
    await db.delete(
      'card_instances',
      where: 'file_id = ?',
      whereArgs: [fileId],
    );
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}////翻译界面数据库代码完毕