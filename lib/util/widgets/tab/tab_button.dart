import 'package:flutter/material.dart';

/// 通用标签切换按钮
/// 用于在应用中多处复用的标签页切换按钮
class TabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;

  const TabButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = Colors.white,
    this.unselectedColor = Colors.grey,
    this.selectedTextColor = Colors.black,
    this.unselectedTextColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? selectedTextColor : unselectedTextColor,
          ),
        ),
      ),
    );
  }
}