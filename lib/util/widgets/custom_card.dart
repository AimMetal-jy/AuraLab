import 'package:flutter/material.dart';

/// 通用卡片组件
/// 在应用中多处复用的卡片UI组件
/// 统一了卡片的样式，包括圆角、阴影等
/// 提供一致的视觉体验，简化卡片创建过程
class CustomCard extends StatelessWidget {
  /// 卡片内部的子组件
  final Widget child;
  /// 卡片的阴影高度
  final double elevation;
  /// 卡片的圆角半径
  final double borderRadius;
  /// 卡片内部的内边距
  final EdgeInsetsGeometry? padding;
  /// 卡片的背景颜色
  final Color? color;
  /// 卡片点击事件回调
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.elevation = 10, // 默认阴影高度
    this.borderRadius = 20, // 默认圆角半径
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)), // 设置圆角
      ),
      elevation: elevation, // 设置阴影
      color: color, // 设置背景色
      child: Padding(
        padding: padding ?? EdgeInsets.zero, // 设置内边距，如果未提供则为零
        child: child, // 卡片内容
      ),
    );

    // 如果提供了点击回调，则包装在InkWell中以支持点击效果
    if (onTap != null) {
      return InkWell(
        onTap: onTap, // 点击回调
        borderRadius: BorderRadius.circular(borderRadius), // 保持与卡片相同的圆角
        child: card, // 卡片组件
      );
    }

    return card; // 如果没有点击回调，直接返回卡片
  }
}