import 'package:flutter/material.dart';

/// 通用页面标题组件
/// 在应用中多处复用的AppBar标题组件
/// 包含图标和文本的标准化页面标题
/// 提供统一的标题样式，增强应用的一致性
class PageTitle extends StatelessWidget {
  /// 标题文本
  final String title;
  /// 标题图标
  final IconData icon;
  /// 图标和文本之间的间距
  final double spacing;
  /// 标题文本样式
  final TextStyle? textStyle;
  /// 图标颜色
  final Color? iconColor;

  const PageTitle({
    super.key,
    required this.title,
    required this.icon,
    this.spacing = 5, // 默认间距为5
    this.textStyle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // 行宽度适应内容
      children: [
        Icon(icon, color: iconColor ?? Colors.black), // 显示图标，默认黑色
        SizedBox(width: spacing), // 图标和文本之间的间距
        Text(
          title,
          style: textStyle ?? const TextStyle(color: Colors.black), // 文本样式，默认黑色
        ),
        const SizedBox(width: 15), // 右侧额外间距
      ],
    );
  }
}