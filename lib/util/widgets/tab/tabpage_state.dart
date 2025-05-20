import 'package:flutter/material.dart';

/// 通用页面索引状态管理
/// 可在应用中多处复用的标签页状态管理组件
/// 用于替代各个页面中重复的InheritedNotifier实现
/// 提供统一的标签页状态管理方式，简化页面切换逻辑
class TabState extends InheritedNotifier<ValueNotifier<int>> {
  const TabState({
    super.key,
    required super.notifier,
    required super.child,
  });

  /// 获取当前索引值
  /// 
  /// 从上下文中获取当前选中的标签页索引
  /// 如果找不到TabState，则返回默认值0
  static int of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<TabState>()
            ?.notifier
            ?.value ??
        0; // 默认返回0
  }

  /// 切换页面索引
  /// 
  /// 用于在标签页之间进行切换
  /// 通过修改ValueNotifier的值触发UI更新
  static void switchPage(BuildContext context, int index) {
    final notifier = context
        .dependOnInheritedWidgetOfExactType<TabState>()
        ?.notifier;
    if (notifier != null) {
      notifier.value = index; // 更新索引值
    }
  }

  @override
  bool updateShouldNotify(TabState oldWidget) {
    return notifier != oldWidget.notifier; // 当notifier发生变化时通知依赖项更新
  }
}