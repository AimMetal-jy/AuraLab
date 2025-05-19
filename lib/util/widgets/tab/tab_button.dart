import 'package:flutter/material.dart';

/// 通用标签切换按钮
/// 用于在应用中多处复用的标签页切换按钮
/// 提供统一的标签样式和交互效果，增强用户体验
class TabButton extends StatelessWidget {
  /// 按钮显示的文本
  final String text;
  /// 是否为选中状态
  final bool isSelected;
  /// 点击事件回调
  final VoidCallback onTap;
  /// 选中状态的背景颜色
  final Color selectedColor;
  /// 未选中状态的背景颜色
  final Color unselectedColor;
  /// 选中状态的文本颜色
  final Color selectedTextColor;
  /// 未选中状态的文本颜色
  final Color unselectedTextColor;

  const TabButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = Colors.white, // 默认选中颜色为白色
    this.unselectedColor = Colors.grey, // 默认未选中颜色为灰色
    this.selectedTextColor = Colors.black, // 默认选中文本颜色为黑色
    this.unselectedTextColor = Colors.white, // 默认未选中文本颜色为白色
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // 点击事件处理
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0), // 内边距
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor, // 根据选中状态切换背景色
          borderRadius: BorderRadius.circular(15), // 圆角边框
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14, // 文本大小
            color: isSelected ? selectedTextColor : unselectedTextColor, // 根据选中状态切换文本颜色
          ),
        ),
      ),
    );
  }
}