import 'package:flutter/material.dart';

/// 通用页面标题组件
/// 在应用中多处复用的AppBar标题组件
/// 包含图标和文本的标准化页面标题
class PageTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final double spacing;
  final TextStyle? textStyle;
  final Color? iconColor;

  const PageTitle({
    super.key,
    required this.title,
    required this.icon,
    this.spacing = 5,
    this.textStyle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor ?? Colors.black),
        SizedBox(width: spacing),
        Text(
          title,
          style: textStyle ?? const TextStyle(color: Colors.black),
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}