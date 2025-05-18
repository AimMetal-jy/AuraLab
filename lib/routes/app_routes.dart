import 'package:flutter/material.dart';
import 'package:auralab/screens/listening/listening.dart';
import 'package:auralab/screens/menu/menu.dart';
import 'package:auralab/screens/notes/notes.dart';
import 'package:auralab/screens/settings/settings.dart';
import 'package:auralab/screens/translate/translate.dart';
import 'package:auralab/screens/vocabulary/vocabulary.dart';

/// 应用路由管理类
/// 定义所有页面的路由常量和路由生成器
class AppRoutes {
  // 路由名称常量
  static const String listening = '/listening';
  static const String notes = '/notes';
  static const String translate = '/translate';
  static const String vocabulary = '/vocabulary';
  static const String settings = '/settings';
  
  // 初始路由
  static const String initialRoute = listening;
  
  // 路由表
  static Map<String, WidgetBuilder> routes = {
    listening: (context) => const ListeningPage(),
    notes: (context) => const Notes(),
    translate: (context) => const TranslatePage(),
    vocabulary: (context) => const VocabularyPage(),
    settings: (context) => const Settings(),
  };
  
  // 未知路由处理
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const ListeningPage(),
    );
  }
}