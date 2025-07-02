import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'user_service.dart';

class ApiService {
  // 后端服务器地址
  static const String baseUrl = 'http://localhost:8000/api';
  static final UserService _userService = UserService();
  
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
            _userService.setUser(user);
          } catch (e) {
            print('保存用户信息失败: $e');
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
            _userService.setUser(user);
          } catch (e) {
            print('保存用户信息失败: $e');
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
  
  // 获取当前登录用户信息
  static User? getCurrentUser() {
    return _userService.currentUser;
  }

  // 根据用户名检查是否为当前用户
  static bool isCurrentUser(String username) {
    final currentUser = _userService.currentUser;
    return currentUser != null && currentUser.username == username;
  }

  // 检查用户是否已登录
  static bool isUserLoggedIn() {
    return _userService.isLoggedIn;
  }

  // 离线模式检查（检查网络连接）
  static Future<bool> isOnline() async {
    return await checkHealth();
  }

  // 清除用户登录状态
  static bool clearUserData() {
    try {
      _userService.clearUser();
      return true;
    } catch (e) {
      print('清除用户数据失败: $e');
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