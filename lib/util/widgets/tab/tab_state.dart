import 'package:flutter/material.dart';

/// 通用页面索引状态管理
/// 可在应用中多处复用的标签页状态管理组件
/// 用于替代各个页面中重复的InheritedNotifier实现
class TabState extends InheritedNotifier<ValueNotifier<int>> {
  const TabState({
    super.key,
    required super.notifier,
    required super.child,
  });

  /// 获取当前索引值
  static int of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<TabState>()
            ?.notifier
            ?.value ??
        0;
  }

  /// 切换页面索引
  static void switchPage(BuildContext context, int index) {
    final notifier = context
        .dependOnInheritedWidgetOfExactType<TabState>()
        ?.notifier;
    if (notifier != null) {
      notifier.value = index;
    }
  }

  @override
  bool updateShouldNotify(TabState oldWidget) {
    return notifier != oldWidget.notifier;
  }
}