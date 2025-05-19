import 'package:flutter/material.dart';

/// 自定义菜单按钮组件
/// 可在应用中多处复用的菜单按钮
/// 提供统一的外观和交互体验，用于菜单项的显示
class MenuButton extends StatelessWidget {
  /// 按钮显示的文本
  final String text;
  /// 按钮点击回调函数
  final VoidCallback? onPressed;
  
  const MenuButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 32), // 左侧边距
        Expanded(
          child: GestureDetector(
            onTap: onPressed, // 点击事件处理
            child: Container(
              height: 48, // 固定高度
              decoration: BoxDecoration(
                color: Colors.grey[350], // 浅灰色背景
                borderRadius: BorderRadius.circular(12), // 圆角边框
              ),
              alignment: Alignment.center, // 内容居中对齐
              child: Text(
                text,
                style: const TextStyle(fontSize: 16, color: Colors.black87), // 文本样式
              ),
            ),
          ),
        ),
        const SizedBox(width: 16), // 右侧边距
        const SizedBox(width: 16), // 额外的右侧边距
      ],
    );
  }
}