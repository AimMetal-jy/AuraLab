import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  User? _currentUser;
  bool _isLoggedIn = false;

  // Getter
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  String? get username => _currentUser?.username;

  // 设置当前用户
  void setUser(User user) {
    _currentUser = user;
    _isLoggedIn = true;
    notifyListeners();
    
    // 这里可以添加保存到本地存储的逻辑
    _saveUserToLocal(user);
  }

  // 清除用户信息（登出）
  void clearUser() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
    
    // 这里可以添加清除本地存储的逻辑
    _clearUserFromLocal();
  }

  // 检查登录状态
  bool checkLoginStatus() {
    // 这里可以添加从本地存储读取用户信息的逻辑
    return _isLoggedIn;
  }

  // 保存用户信息到本地存储（占位符）
  void _saveUserToLocal(User user) {
    // TODO: 实现本地存储逻辑
    // 可以使用 shared_preferences 或其他本地存储方案
    if (kDebugMode) {
      print('保存用户信息到本地: ${user.username}');
    }
  }

  // 从本地存储清除用户信息（占位符）
  void _clearUserFromLocal() {
    // TODO: 实现清除本地存储逻辑
    if (kDebugMode) {
      print('清除本地用户信息');
    }
  }

  // 从本地存储加载用户信息（占位符）
  Future<void> loadUserFromLocal() async {
    // TODO: 实现从本地存储加载用户信息的逻辑
    if (kDebugMode) {
      print('从本地存储加载用户信息');
    }
  }
}