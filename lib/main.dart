import 'package:flutter/material.dart';
import 'package:auralab/routes/app_routes.dart';

/// 应用程序入口点
/// 初始化并启动文枢工坊(AuraLab)应用
void main() {
  runApp(const MyApp());
}

/// 应用程序根组件
/// 配置应用的主题、路由和全局设置
class MyApp extends StatelessWidget {
  /// 创建一个MyApp实例
  /// 
  /// super.key为必有格式
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 关闭调试标签
      debugShowCheckedModeBanner: false,
      // 应用标题，显示在任务管理器中
      title: "AuraLab",
      // 设置初始路由
      initialRoute: AppRoutes.initialRoute,
      // 注册应用的所有路由
      routes: AppRoutes.routes,
      // 处理未知路由的回调
      onUnknownRoute: AppRoutes.onUnknownRoute,
      // 设置iOS风格的页面切换动画
      theme: ThemeData(
        platform: TargetPlatform.iOS,
      ),
    );
  }
}