import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 后端服务器地址
  static const String baseUrl = 'http://localhost:8000/api';
  
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
        // 注册成功
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
        // 登录成功
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
}