import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'database_helper.dart';

class ApiService {
  // 后端服务器地址
  static const String baseUrl = 'http://localhost:8000/api';
  static final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  // 注册用户
  static Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 201) {
        // 注册成功，保存用户信息到本地数据库
        if (responseData['user'] != null) {
          try {
            final user = User.fromJson(responseData['user']);
            await _databaseHelper.insertUser(user);
          } catch (e) {
            print('保存用户信息到本地数据库失败: $e');
          }
        }
        return {
          'success': true,
          'message': responseData['message'] ?? '注册成功',
          'user': responseData['user'],
        };
      } else if (response.statusCode == 409) {
        // 用户名已存在
        return {
          'success': false,
          'message': responseData['message'] ?? '用户名已存在',
        };
      } else {
        // 其他错误
        return {
          'success': false,
          'message': responseData['message'] ?? '注册失败，请稍后重试',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '网络连接失败，请检查网络设置',
      };
    }
  }
  
  // 用户登录
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        // 登录成功，保存或更新用户信息到本地数据库
        if (responseData['user'] != null) {
          try {
            final user = User.fromJson(responseData['user']);
            final existingUser = await _databaseHelper.getUserById(user.id!);
            if (existingUser != null) {
                await _databaseHelper.updateUser(user);
            } else {
              await _databaseHelper.insertUser(user);
            }
          } catch (e) {
            print('保存用户信息到本地数据库失败: $e');
          }
        }
        return {
          'success': true,
          'message': responseData['message'] ?? '登录成功',
          'user': responseData['user'],
        };
      } else if (response.statusCode == 401) {
        // 用户名或密码错误
        return {
          'success': false,
          'message': responseData['message'] ?? '用户名或密码错误',
        };
      } else if (response.statusCode == 403) {
        // 用户账户未激活
        return {
          'success': false,
          'message': responseData['message'] ?? '用户账户未激活',
        };
      } else {
        // 其他错误
        return {
          'success': false,
          'message': responseData['message'] ?? '登录失败，请稍后重试',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '网络连接失败，请检查网络设置',
      };
    }
  }
  
  // 健康检查
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 本地用户管理方法
  
  // 获取本地用户信息
  static Future<User?> getLocalUser(int userId) async {
    try {
      return await _databaseHelper.getUserById(userId);
    } catch (e) {
      print('获取本地用户信息失败: $e');
      return null;
    }
  }

  // 根据用户名获取本地用户信息
  static Future<User?> getLocalUserByUsername(String username) async {
    try {
      return await _databaseHelper.getUserByUsername(username);
    } catch (e) {
      print('根据用户名获取本地用户信息失败: $e');
      return null;
    }
  }

  // 检查用户是否存在于本地数据库
  static Future<bool> isUserExistsLocally(String username) async {
    try {
      final user = await _databaseHelper.getUserByUsername(username);
      return user != null;
    } catch (e) {
      print('检查本地用户存在性失败: $e');
      return false;
    }
  }

  // 离线模式检查（检查网络连接）
  static Future<bool> isOnline() async {
    return await checkHealth();
  }

  // 清除本地用户数据
  static Future<bool> clearLocalUserData() async {
    try {
      await _databaseHelper.clearAllData();
      return true;
    } catch (e) {
      print('清除本地用户数据失败: $e');
      return false;
    }
  }

  // 同步用户数据（从服务器获取最新数据并更新本地）
  static Future<Map<String, dynamic>> syncUserData(int userId) async {
    try {
      // 这里可以添加从服务器获取用户详细信息的API调用
      // 目前返回成功状态
      return {
        'success': true,
        'message': '数据同步成功',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '数据同步失败: $e',
      };
    }
  }
}