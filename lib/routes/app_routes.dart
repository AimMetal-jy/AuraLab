import 'package:flutter/material.dart';
import 'package:auralab/screens/documents/documents.dart';
import 'package:auralab/screens/notes/notes.dart';
import 'package:auralab/screens/settings/settings.dart';
import 'package:auralab/screens/translate/translate.dart';
import 'package:auralab/screens/vocabulary/vocabulary.dart';
import 'package:auralab/screens/search/search_page.dart';

/// 应用路由管理类
/// 定义所有页面的路由常量和路由生成器
/// 
/// 该类负责集中管理应用中所有页面的路由信息，包括路由名称、路由映射和未知路由处理
/// 使用静态成员确保全局一致的路由访问
class AppRoutes {
  /// 路由名称常量
  /// 定义应用中各页面的路由路径
  static const String documents = '/documents'; // 文档练习页面路由
  static const String notes = '/notes';         // 笔记页面路由
  static const String translate = '/translate'; // 翻译页面路由
  static const String vocabulary = '/vocabulary'; // 词汇学习页面路由
  static const String settings = '/settings';   // 设置页面路由
  static const String search = '/search';       // 搜索页面路由
  /// 应用初始路由
  /// 定义应用启动时显示的第一个页面
  static const String initialRoute = documents;
  
  /// 应用路由表
  /// 将路由名称映射到对应的页面构建器函数
  /// 当导航到命名路由时，Flutter会使用这个映射表查找对应的页面构建器
  static Map<String, WidgetBuilder> routes = {
    documents: (context) => const DocumentsPage(),
    notes: (context) => const Notes(),
    translate: (context) => const TranslatePage(),
    vocabulary: (context) => const VocabularyPage(),
    settings: (context) => const Settings(),
    search: (context) => const SearchPage(),
  };
  
  /// 未知路由处理器
  /// 当应用尝试导航到未在路由表中定义的路由时调用
  /// 
  /// [settings] 包含有关请求的路由的信息
  /// 
  /// 返回一个回退路由，将用户导航到文档练习页面
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    // 对于未知路由，默认导航到文档练习页面
    return MaterialPageRoute(
      builder: (context) => const DocumentsPage(),
    );
  }
}