import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'auralab.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建用户表
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 创建笔记表
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 创建音频记录表
    await db.execute('''
      CREATE TABLE audio_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        file_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        duration INTEGER,
        transcription TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 创建词汇表
    await db.execute('''
      CREATE TABLE vocabulary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        word TEXT NOT NULL,
        translation TEXT,
        pronunciation TEXT,
        example_sentence TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 创建应用设置表
    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        setting_key TEXT NOT NULL,
        setting_value TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 数据库升级逻辑
    if (oldVersion < newVersion) {
      // 在这里添加数据库升级逻辑
    }
  }

  // 用户相关操作
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', {
      'id': user.id,
      'username': user.username,
      'created_at': user.createdAt.toIso8601String(),
      'updated_at': user.updatedAt.toIso8601String(),
      'is_active': user.isActive ? 1 : 0,
    });
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson({
        'id': maps.first['id'],
        'username': maps.first['username'],
        'created_at': maps.first['created_at'],
        'updated_at': maps.first['updated_at'],
        'is_active': maps.first['is_active'] == 1,
      });
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromJson({
        'id': maps.first['id'],
        'username': maps.first['username'],
        'created_at': maps.first['created_at'],
        'updated_at': maps.first['updated_at'],
        'is_active': maps.first['is_active'] == 1,
      });
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      {
        'username': user.username,
        'updated_at': DateTime.now().toIso8601String(),
        'is_active': user.isActive ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 清空所有数据
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('notes');
    await db.delete('audio_records');
    await db.delete('vocabulary');
    await db.delete('app_settings');
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}